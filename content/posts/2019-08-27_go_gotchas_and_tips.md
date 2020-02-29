---
title: "Go: small tips, advice, and some gotchas"
date: 2019-08-27
author: "chrsm"
description: "Common issues and a few tips to take into account when programming in Go"
---

Go is a very easy language to learn and quickly become productive with.
As with any language, though, lack of experience can easily make even the
simplest of code hard to maintain.

This post is intended to help with:

- common mistakes
- mechanics of certain builtins
- do-s and don't-s

I will not pretend to be an expert nor a 10xer ninja. Feel free to correct me
if I make any silly claims or am wrong. Email's obvious - c @.


### gofmt urself

Just format your code. Add a Go plugin for your editor that supports formatting on save.

Extra credit for using gofmt's better looking cousin, [gofumpt](https://github.com/mvdan/gofumpt).

I mean, this is obvious. It's pointed out in the tour. Definitely one of the
benefits of writing Go is that we all have the same style.


### A word on concurrency

One of Go's biggest selling points is the built-in mechanisms for concurrency
and synchronization. The implementation isn't revolutionary, but it is simpler
to _use_ than many other languages and much less resource heavy. 
...but while it may be simpler to use, it isn't necessarily easier to use correctly.

It might go without saying, but first and foremost: if what you're authoring
can be considered a "library": don't use concurrency in it. Allow callers
as much control as possible. If the problem space naturally fits, go for it,
but always allow the caller to control what the callees are doing.

For "user" code, I tend to take a cautionary approach:

I believe that the best way to write concurrent code is to start out with
synchronous code. Once the desired behaviour has been implemented, finding
parts of the flow that can actually _benefit_ from concurrent execution
is much simpler.

There is a balance to be struck: will making 5 http calls, synchronously, make
parts of your software slow? Sure.
What about making 5 http calls asynchronously? Can you handle these occurring
hundreds of times a second? Maybe


As unfortunate as it is to resort to saying something incredibly generic:
use your best judgement. Not everything needs to be done at the same time,
and some things naturally rely on some kind of if-then that don't even make
sense to do concurrently.

Examples of this could be a post all by itself, so I'll defer any until I have
time to write something up.


### make

`make` is a builtin that handles creation of maps, channels, and slices.
It is not like `new` - `make(T)` is not valid code.

`make` actually initializes the "builtin" type - not the `T`, but the builtin of `T`
(`map[T]T2`, `chan T`, `[]T`). That is:

- `make(map[T]T2)` initializes the _map_
- `make(chan T)` initializes the _chan_
- `make([]T, len, cap)` initializes the _slice_, elements and backing array
- `make([]*T, len, cap)` initializes the _slice_ and backing array for pointers to `T`

For example, if `map` was initialized like custom types, it'd look something
like the following (not valid code, obviously):

```
m := map{
	keyType: T,
	elementType: T2,
	... buckets, etc ...
}
```

Similarly, a `slice` would look something like:

```
s := slice{
	elementType: T,
	len: int,
	cap: int,
	array: [len]T,
}
```

Note that `make` doesn't return a _pointer_ to these types, but values.
This is why, when appending to a slice, you must assign the value of
`append` back to the value - eg `x = append(x, ...)`.

Channels and maps are even further special-cased. Maps, in particular,
do not need to be reassigned - allocations are handled internally.


### new vs &T{}

Use of `new` and `&T{}` often confuse newcomers to Go. Which should be used,
and why?

- `new(T)` allocates a new `T`, zeroing out values, and returns a pointer to it.
- `&T{}` allocates a new `T`, zeroing out values, and returns a pointer to it.

Essentially, `new` and a literal `&T{}` do the same thing. While `new` is a
builtin, it offers no way to initialize members of `T` inline. It isn't
necessarily wrong per-se, but most idiomatic Go tends to use `&T{}` when
additional initialization is required.

If your type has a useful zero value, `new(T)` is more than fine. For example,
stdlib's `bytes.Buffer` is often created with `new(bytes.Buffer)` rather than
`&bytes.Buffer{}`, as the zero value can be used immediately.

A small benefit to `new` is that you can immediately call a method receiver on
the type. I don't see this often, though.


#### Common `make([]T, ...)` gotcha

`make(T, ...int)` is a simple function that allocates slices' backing, maps,
and channels. In the case of `slices`, the signature is
`make([]T, length, capacity)`. One of the most common bugs is during initial
creation of a slice followed by `append`.

```
slice := make([]T, 10)

for i := range x {
	slice = append(slice, x[i])
}
```

In this case, the slice is created with 10 zero-val'd `T`s. `append` ends up
reallocating room for the elements in `x`, causing the slice to actually have a
length of `10 + len(x)`, which in most cases is not what's actually desired -
usually we're trying to eliminate the need for `append` to reallocate backing
for the slice.

The appropriate way to do this is to set the `cap` of the slice, not the length:

`make([]T, 0, 10)`

`length` specifies the initial number of `T` elements and `capacity` specifies
the size of the underlying array used by the slice. Thus `capacity` may be
greater than or equal to `length` but no less.

If the length of `x` is known at the time of the creation of the slice, and `i`
is an integer, the following solution is also perfectly valid and clear:

```
slice := make([]T, len(x))

for i := range x {
	slice[i] = x
}
```

I would say to prefer the latter as it is what you would expect to see in any
other C-like.


### A bit about interfaces

Go's interfaces are very powerful for
preventing code from being tightly coupled. The stdlib contains a large amount
of simple interfaces that are often ignored by new developers - who instead
pass concrete types around where a simple interface would suffice. While there
are some cases where interfaces should be avoided (hot paths), it is generally
advised to use them until you have reason not to.

Accepting interfaces makes code clearer: to callers, it signals the intended use
and enforces limits on what can be done. To illustrate this, here's a quick look at
the `io` interfaces.

### io.Reader, io.Writer, ...

The `io` package has quite a few common interfaces for - you guessed it -
handling input and output. Off the top of my head, I count 15. Certainly there
are a few more that I can't remember.

The most popular are the obvious: `io.Reader` and `io.Writer`.

`io.Reader` - specifies a `Read(dst []byte) (n int, e error)` method. The implementation
of `Read` should read up to the length of the supplied byte slice and return the
number of bytes read *and/or* an error. Emphasis on the "and/or"! Depending
on the use case, it may be prudent to return `len(src)` as `n` while still returning
an error - such as `io.EOF` to indicate the end of the source was reached.


`io.Writer` - specifies a `Write(src []byte) (n int, e error)` method. The
implementation of `Write` should write up to `len(src)` bytes and return an
error if `len(src) != n`.


We'll examine `io.Writer` for a common use-case: serialization.
For example, a simple type `SaveMe`.

```
type SaveMe struct {
	data []byte
}
```

`SaveMe` is a boring type that just has an array of bytes in it.
We don't need to do anything fancy except write these out to disk.

```
func (s *SaveMe) Serialize(fp *os.File) error {
	nbytes := uint8(len(s.data))
	if n, err := fp.Write(byte(nbytes)); n != 1 || err != nil {
		return errors.New("failed to write length of data")
	}

	n, err := fp.Write(s.data)
	if n != len(data) {
		return errors.New("short write")
	}

	return err
}
```

Doesn't look too bad, right? Let's write an accompanying test for `SaveMe`'s
serialization process.

```
func TestSerializeToFile(t *testing.T) {
	s := &SaveMe{
		data: []byte("i just wanna make sure this works :("),
	}

	f, err := os.OpenFile("/tmp/xyz", os.O_WRONLY|os.O_CREATE, 0777)
	if err != nil {
		t.Fatal("couldn't open file for testing")
	}
	defer f.Close()

	err = s.Serialize(f)
	if err != nil {
		t.Fatalf("failed to serialize %v: %s", s, err)
	}

	f.Seek(0, os.SEEK_SET)
	buf := make([]byte, 1 + len(s.data))
	if _, err := f.Read(buf); err != nil {
		t.Fatalf("couldn't read from file: %s", err)
	}

	if bytes.Compare(buf[1:], s.data) != 0 {
		t.Fatal("read buf != s.data")
	}
}
```

Alright, now we've got a few extra lines to handle creation of a temporary file.
And to close it. And to seek back to the beginning. And then to read the data
out of it. Oops - we never deleted the file after the tests run, and neglected
to use `os.O_TRUNC` to ensure the file is truncated. What if some other dumb test
tries to write to `/tmp/xyz`? What if there's no writable disk at all?

New ticket comes in - you've got to read and write this type over the network.
Better just re-read that file and conn.Write it over! `/s`
We also need to be able to present this as the body of an `*http.Response` now!
Feature creep here we come!

```
func (s *SaveMe) SerializeFile(*os.File) ...
func (s *SaveMe) SerializeConn(net.Conn) ...
func (s *SaveMe) SerializeHTTP(*http.Response) ...
```

Nah. Good code is simple and eliminates repetition where reasonable, and we can
actually just write a single method!


```
func (s *SaveMe) WriteTo(w io.Writer) (int, error) {
	n, err := w.Write(s.data)
	if n != len(s.data) {
		...
	}

	return err
}
```

In tests, we can drop the file requirement completely:

```
func TestSerializeToWriter(t *testing.T) {
	s := &SaveMe{
		data: []byte("i just wanna make sure this works :("),
	}

	buf := new(bytes.Buffer)
	if err := s.WriteTo(buf); err != nil {
		t.Fatalf("failed to write to buffer: %s", err)
	}

	dst := buf.Bytes()
	if bytes.Compare(dst[1:], s.data) != 0 {
		t.Fatal("buf != s.data")
	}
}
```

Now - there's no file worries whatsoever and we still know that the contents
of `SaveMe` make its way through - whether it's to disk, a bare network
connection, whatever - sans destination-specific errors. (Side note: our 
implementation here also satisfies the `io.WriterTo` interface!)


### ...and Error Handling

At this point, we've got an abstract serialization method that doesn't care
where it writes to, so long as it gets written. That's not the full story,
though, is it? Inevitably, there will be errors. And the common Go meme
of `if err != nil` rears its ugly head, here - what do we do about implementation
specific errors?

To that, I say: it depends(TM).

If we're dealing with files, good luck. If we're dealing with a network
connection - the other side may be able to understand the hiccup and allow for
retransmission. If so, it doesn't seem like something our tiny little `SaveMe`
should be responsible for, and rather should be the caller's job to handle.

The caller may have a `net.Conn`. It may not. If it doesn't, we can use type
assertion to figure out that it was a network issue:

```
if neterr, ok := err.(net.Error); ok {
	// it's a net.Error, so use it's methods to see if we can retry.
}
```

The caller can also use their own interfaces to assert for behaviour, rather
than a package-specific type. To do so, we'd write our own interface for
`net.Error`'s Timeout check:

```
type timeoutError interface {
	Timeout() bool
}

if terr, ok := err.(timeoutError); ok && terr.Timeout() {
	// it's specifically a timeout, so wait and try again
}
```

The second case - being our own interface - allows us to test for a timeout
scenario without implementing the full `net.Error` interface.

Not all cases will be so simple, but checking behaviour instead of specific
types is exactly why we went with `io.Writer` for `SaveMe` in the first place.
It signals how something is intended to be used and explicitly limits to that
use.


### The Dreaded`interface{}`

`interface{}` is an actual _interface_ with no methods - hence why it is called
the "empty interface".

Because it has no methods specified, it can hold any type - struct, slice, map,
you name it - it holds it.

One issue that comes to mind with the empty interface value is nil checks:

```
func retinterface(b bool) interface{} {
	type x struct {}

	var ret *x

	if b {
		ret = &x{}
	}

	return ret
}
```


- Call `retinterface(true)`. Is the return value nil? Nope!
- Call `retinterface(false)`. Is the return value nil? Nope! Wait, what?

What we're actually getting here is a nil pointer to an `x`. It's fairly
obvious in hindsight, but common enough that it should be noted.

Instead of returning a nil `x`, we'd want to do the following:

```
func retinterface(b bool) interface{} {
	type x struct {}

	if !b {
		return nil
	}

	return &x{}
}
```

Which will properly return a bare `nil` rather than a nil ptr to an `x`.

Generally, `interface{}` is used by "generic" code that handles unknown types.
`fmt`, `log`, `encoding/json`, ... the list goes on. It has uses, but it should
not be sprinkled around a codebase for ease of use.

Given the signature `func do(v interface{})`, we know `do` can _accept_ any type
of value, but not whether it can actually do anything with it. That, of course,
depends on the implementation of `do`. Personally, not a big fan of this unless
you're writing some ultra-generic library code. Let's hope Go contracts
materialize into something useful.

There's not much else to say here other than "avoid the empty interface where
you can". Use an actual interface that describes what you need.


### Fin

;wq
