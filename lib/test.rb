require "./csound.rb"

cs = Csound.new
cs.CompileCsd("test.csd")
cs.Start()

cs.Perform()