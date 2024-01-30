# Csound for Ruby

Ruby interface to Csound 6 API through FFI.
This interface does not contain the full Csound API.

# Examples 
A simple examples for CsoundModule : 

The same example using Csound class : 
```ruby
require "csound"
cs = Csound.new
res = cs.CompileCsd("path/to/mycsd.csd") 
res = cs.Start() if res == 0
res = cs.Perform() if res == 0
```
# More 

As it is a simple bridge to Csound API, you can get more informations by visiting [Csound website](https://csound.com/), and particularly looking at csound.h header file of Csound API. 




