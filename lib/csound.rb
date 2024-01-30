require "bundler/inline"

gemfile do
	source "https://rubygems.org"
	gem "ffi", require: true
    gem "os", require: true 
end

def convert_to_binary(integer)
  binary = []
  while integer > 0
    binary << integer % 2
    integer /= 2
  end
  binary.reverse.join
end

module ControlChannelType
	CSOUND_CONTROL_CHANNEL = 1
	CSOUND_AUDIO_CHANNEL = 2
	CSOUND_STRING_CHANNEL = 3
	CSOUND_PVS_CHANNEL = 4
	CSOUND_VAR_CHANNEL = 5

	CSOUND_CHANNEL_TYPE_MASK = 15
	CSOUND_INPUT_CHANNEL = 16
	CSOUND_OUTPUT_CHANNEL = 32
end

module ControlChannelBehavior 
	CSOUND_CONTROL_CHANNEL_NO_HINTS = 0
	CSOUND_CONTROL_CHANNEL_INT = 1
	CSOUND_CONTROL_CHANNEL_LIN = 2
	CSOUND_CONTROL_CHANNEL_EXP = 3
end

class ControlChannelHints_t < FFI::Struct
	layout :behav, :int, #controlChannelBehavior
		:dflt, :double,
		:min, :double,
		:max, :double,
		:x, :int,
		:y, :int,
		:width, :int,
		:height, :int,
		:attributes, :pointer	# char *
end

class ControlChannelInfo_t < FFI::Struct
	layout :name, :string, # char *
		:type, :int,
		:hints, ControlChannelHints_t
end

class CS_TYPE < FFI::Struct
  layout :varTypeName,:string,
         :varDescription,:string,
         :argtype,:int,
         :createVariable,:pointer,
         :copyValue,:pointer,
         :unionTypes,:pointer,
         :freeVariableMemory,:pointer
        
end

def get_possible_paths
	if(OS.linux?) then 
		return ["libcsound64.so", 
			"/usr/local/lib/libcsound64.so", 
			"/usr/lib/libcsound64.so"]
	elsif(OS.mac?) then 
		return ["CsoundLib64", 
			"/Library/Frameworks/CsoundLib64.framework/Versions/6.0/CsoundLib64"]
	elsif(OS.windows) then 
		return ["csound64", "csound64.dll", 
			"C:/Program Files/Csound6_x64/csound64.dll", 
			"C:/Program Files/Csound6_x64/lib/csound64.dll", 
			"C:/Program Files/Csound6_x64/bin/csound64.dll" ]
	end
end

module CsoundModule
	extend FFI::Library
	ffi_lib get_possible_paths

	attach_function :csoundCreate,[:pointer],:pointer
	attach_function :csoundInitialize,[:int],:int
	attach_function :csoundDestroy,[:pointer],:void
	attach_function :csoundGetVersion,[],:int
	attach_function :csoundGetAPIVersion,[],:int
	attach_function :csoundCompileTree,[:pointer,:pointer],:int
	attach_function :csoundCompileTreeAsync,[:pointer,:pointer],:int
	attach_function :csoundDeleteTree,[:pointer,:pointer],:void
	attach_function :csoundCompileOrc,[:pointer,:string],:int
	attach_function :csoundCompileOrcAsync,[:pointer,:string],:int
	attach_function :csoundEvalCode,[:pointer,:string],:double
	attach_function :csoundInitializeCscore,[:pointer,:pointer,:pointer],:int
	attach_function :csoundCompileArgs,[:pointer,:int,:pointer],:int
	attach_function :csoundStart,[:pointer],:int
	attach_function :csoundCompile,[:pointer,:int,:pointer],:int
	attach_function :csoundCompileCsd,[:pointer,:string],:int
	attach_function :csoundCompileCsdText,[:pointer,:string],:int
	attach_function :csoundPerform,[:pointer],:int
	attach_function :csoundPerformKsmps,[:pointer],:int
	attach_function :csoundPerformBuffer,[:pointer],:int
	attach_function :csoundStop,[:pointer],:void
	attach_function :csoundCleanup,[:pointer],:int
	attach_function :csoundReset,[:pointer],:void
	attach_function :csoundUDPServerStart,[:pointer,:uint],:int
	attach_function :csoundUDPServerStatus,[:pointer],:int
	attach_function :csoundUDPServerClose,[:pointer],:int
	attach_function :csoundStopUDPConsole,[:pointer],:void
	attach_function :csoundGetKr,[:pointer],:double
	attach_function :csoundGetKsmps,[:pointer],:uint32
	attach_function :csoundGetNchnls,[:pointer],:uint32
	attach_function :csoundGetNchnlsInput,[:pointer],:uint32
	attach_function :csoundGetCurrentTimeSamples,[:pointer],:int64
	attach_function :csoundGetSizeOfMYFLT,[],:int
	attach_function :csoundSetHostData,[:pointer,:pointer],:void
	attach_function :csoundSetOption,[:pointer,:string],:int
	attach_function :csoundSetParams,[:pointer,:pointer],:void
	attach_function :csoundGetParams,[:pointer,:pointer],:void
	attach_function :csoundGetDebug,[:pointer],:int
	attach_function :csoundSetDebug,[:pointer,:int],:void
	attach_function :csoundSystemSr,[:pointer,:double],:double
	attach_function :csoundSetInput,[:pointer,:string],:void
	attach_function :csoundSetMIDIInput,[:pointer,:string],:void
	attach_function :csoundSetMIDIFileInput,[:pointer,:string],:void
	attach_function :csoundSetMIDIOutput,[:pointer,:string],:void
	attach_function :csoundSetMIDIFileOutput,[:pointer,:string],:void
	attach_function :csoundSetRTAudioModule,[:pointer,:string],:void
	attach_function :csoundGetInputBufferSize,[:pointer],:long
	attach_function :csoundGetOutputBufferSize,[:pointer],:long
	attach_function :csoundClearSpin,[:pointer],:void
	attach_function :csoundGetSpoutSample,[:pointer,:int,:int],:double
	attach_function :csoundSetRtcloseCallback,[:pointer,:void],:void
	attach_function :csoundSetMIDIModule,[:pointer,:string],:void
	attach_function :csoundReadScore,[:pointer,:string],:int
	attach_function :csoundReadScoreAsync,[:pointer,:string],:void
	attach_function :csoundGetScoreTime,[:pointer],:double
	attach_function :csoundIsScorePending,[:pointer],:int
	attach_function :csoundSetScorePending,[:pointer,:int],:void
	attach_function :csoundGetScoreOffsetSeconds,[:pointer],:double
	attach_function :csoundSetScoreOffsetSeconds,[:pointer,:double],:void
	attach_function :csoundRewindScore,[:pointer],:void
	attach_function :csoundScoreSort,[:pointer,:pointer,:pointer],:int
	attach_function :csoundMessage,[:pointer,:string],:void
	attach_function :csoundGetMessageLevel,[:pointer],:int
	attach_function :csoundSetMessageLevel,[:pointer,:int],:void
	attach_function :csoundCreateMessageBuffer,[:pointer,:int],:void
	attach_function :csoundGetFirstMessageAttr,[:pointer],:int
	attach_function :csoundPopFirstMessage,[:pointer],:void
	attach_function :csoundGetMessageCnt,[:pointer],:int
	attach_function :csoundDestroyMessageBuffer,[:pointer],:void
	attach_function :csoundListChannels,[:pointer,:pointer],:int
	attach_function :csoundDeleteChannelList,[:pointer,:pointer],:void
	attach_function :csoundGetChannelDatasize,[:pointer,:string],:int
	attach_function :csoundInputMessage,[:pointer,:string],:void
	attach_function :csoundInputMessageAsync,[:pointer,:string],:void
	attach_function :csoundKeyPress,[:pointer,:char],:void
	attach_function :csoundTableLength,[:pointer,:int],:int
	attach_function :csoundTableGet,[:pointer,:int,:int],:double
	attach_function :csoundTableSet,[:pointer,:int,:int,:double],:void
	attach_function :csoundTableCopyOut,[:pointer,:int,:pointer],:void
	attach_function :csoundTableCopyOutAsync,[:pointer,:int,:pointer],:void
	attach_function :csoundTableCopyIn,[:pointer,:int,:pointer],:void
	attach_function :csoundTableCopyInAsync,[:pointer,:int,:pointer],:void
	attach_function :csoundGetTable,[:pointer,:pointer,:int],:int
	attach_function :csoundGetTableArgs,[:pointer,:pointer,:int],:int
	attach_function :csoundIsNamedGEN,[:pointer,:int],:int
	attach_function :csoundGetNamedGEN,[:pointer,:int,:pointer,:int],:void
	attach_function :csoundSetIsGraphable,[:pointer,:int],:int
	attach_function :csoundNewOpcodeList,[:pointer,:pointer],:int
	attach_function :csoundDisposeOpcodeList,[:pointer,:pointer],:void
	attach_function :csoundSetYieldCallback,[:pointer,:int],:void
	attach_function :csoundJoinThread,[:pointer],:pointer
	attach_function :csoundWaitThreadLock,[:pointer,:size_t],:int
	attach_function :csoundWaitThreadLockNoTimeout,[:pointer],:void
	attach_function :csoundNotifyThreadLock,[:pointer],:void
	attach_function :csoundDestroyThreadLock,[:pointer],:void
	attach_function :csoundLockMutex,[:pointer],:void
	attach_function :csoundLockMutexNoWait,[:pointer],:int
	attach_function :csoundUnlockMutex,[:pointer],:void
	attach_function :csoundDestroyMutex,[:pointer],:void
	attach_function :csoundDestroyBarrier,[:pointer],:int
	attach_function :csoundWaitBarrier,[:pointer],:int
	attach_function :csoundCondWait,[:pointer,:pointer],:void
	attach_function :csoundCondSignal,[:pointer],:void
	attach_function :csoundSleep,[:size_t],:void
	attach_function :csoundSpinLockInit,[:pointer],:int
	attach_function :csoundSpinLock,[:pointer],:void
	attach_function :csoundSpinTryLock,[:pointer],:int
	attach_function :csoundSpinUnLock,[:pointer],:void
	attach_function :csoundRunCommand,[:pointer,:int],:long
	attach_function :csoundInitTimerStruct,[:pointer],:void
	attach_function :csoundGetRealTime,[:pointer],:double
	attach_function :csoundGetCPUTime,[:pointer],:double
	attach_function :csoundGetRandomSeedFromTime,[],:uint32
	attach_function :csoundSetGlobalEnv,[:string,:string],:int
	attach_function :csoundDestroyGlobalVariable,[:pointer,:string],:int
	attach_function :csoundDeleteUtilityList,[:pointer,:pointer],:void
	attach_function :csoundRandMT,[:pointer],:uint32
	attach_function :csoundFlushCircularBuffer,[:pointer,:pointer],:void
	attach_function :csoundDestroyCircularBuffer,[:pointer,:pointer],:void
	attach_function :csoundOpenLibrary,[:pointer,:string],:int
	attach_function :csoundCloseLibrary,[:pointer],:int

	#Handwritten
	attach_function :csoundSetControlChannel,[:pointer,:string,:double],:void
	attach_function :csoundGetControlChannel,[:pointer,:string,:pointer],:double

	callback :channel_callback_t,[:pointer,:string,:pointer,:pointer],:void
	attach_function :csoundSetInputChannelCallback,[:pointer,:channel_callback_t],:void
	attach_function :csoundSetOutputChannelCallback,[:pointer,:channel_callback_t],:void


	attach_function :csoundGetFirstMessage,[:pointer],:string

	attach_function :csoundGetSr,[:pointer],:double

	attach_function :csoundGetSpout,[:pointer],:pointer
	attach_function :csoundGetSpoutSample,[:pointer,:int,:int],:double


	attach_function :csoundGetSpin,[:pointer],:pointer
	attach_function :csoundClearSpin,[:pointer],:void
	attach_function :csoundAddSpinSample,[:pointer,:int,:int,:double],:double
	attach_function :csoundSetSpinSample,[:pointer,:int,:int,:double],:void


	attach_function :csoundGetEnv,[:pointer,:string],:string
	attach_function :csoundCreateGlobalVariable,[:pointer,:string,:size_t],:int

	attach_function :csoundQueryGlobalVariable,[:pointer,:string],:pointer
	attach_function :csoundQueryGlobalVariableNoCheck,[:pointer,:string],:pointer

	attach_function :csoundRunUtility,[:pointer,:string,:int,:pointer],:int
	attach_function :csoundListUtilities,[:pointer],:pointer
	attach_function :csoundGetUtilityDescription,[:pointer,:string],:string

	attach_function :csoundCreateCircularBuffer,[:pointer,:int,:int],:pointer
	attach_function :csoundReadCircularBuffer,[:pointer,:pointer,:pointer,:int],:int
	attach_function :csoundPeekCircularBuffer,[:pointer,:pointer,:pointer,:int],:int
	attach_function :csoundWriteCircularBuffer,[:pointer,:pointer,:pointer,:int],:int
	#Missing
	#csoundSetMessageCallback
	#csoundSetMessageStringCallback
end

class Csound 
	@csound = nil
	def initialize(flags=0, host_data=nil)
		@csound = CsoundModule.csoundCreate(host_data)
	end

	def Destroy()
		 return CsoundModule.csoundDestroy(@csound) 
	end

	def GetVersion()
		 return CsoundModule.csoundGetVersion() 
	end

	def GetAPIVersion()
		 return CsoundModule.csoundGetAPIVersion() 
	end

	def CompileTree(root)
		 return CsoundModule.csoundCompileTree(@csound, root) 
	end

	def CompileTreeAsync(root)
		 return CsoundModule.csoundCompileTreeAsync(@csound, root) 
	end

	def DeleteTree(tree)
		 return CsoundModule.csoundDeleteTree(@csound, tree) 
	end

	def CompileOrc(str)
		 return CsoundModule.csoundCompileOrc(@csound, str) 
	end

	def CompileOrcAsync(str)
		 return CsoundModule.csoundCompileOrcAsync(@csound, str) 
	end

	def EvalCode(str)
		 return CsoundModule.csoundEvalCode(@csound, str) 
	end

	def InitializeCscore(insco, outsco)
		 return CsoundModule.csoundInitializeCscore(insco, outsco) 
	end

	def CompileArgs(argc, argv)
		 return CsoundModule.csoundCompileArgs(argc, argv) 
	end

	def Start()
		 return CsoundModule.csoundStart(@csound) 
	end

	def Compile(argc, argv)
		 return CsoundModule.csoundCompile(argc, argv) 
	end

	def CompileCsd(csd)
		 return CsoundModule.csoundCompileCsd(@csound, csd) 
	end

	def CompileCsdText(csd)
		 return CsoundModule.csoundCompileCsdText(@csound, csd) 
	end

	def Perform()
		 return CsoundModule.csoundPerform(@csound) 
	end

	def PerformKsmps()
		 return CsoundModule.csoundPerformKsmps(@csound) 
	end

	def PerformBuffer()
		 return CsoundModule.csoundPerformBuffer(@csound) 
	end

	def Stop()
		 return CsoundModule.csoundStop(@csound) 
	end

	def Cleanup()
		 return CsoundModule.csoundCleanup(@csound) 
	end

	def Reset()
		 return CsoundModule.csoundReset(@csound) 
	end

	def UDPServerStart(port)
		 return CsoundModule.csoundUDPServerStart(@csound, port) 
	end

	def UDPServerStatus()
		 return CsoundModule.csoundUDPServerStatus(@csound) 
	end

	def UDPServerClose()
		 return CsoundModule.csoundUDPServerClose(@csound) 
	end

	def StopUDPConsole()
		 return CsoundModule.csoundStopUDPConsole(@csound) 
	end

	def GetKr()
		 return CsoundModule.csoundGetKr(@csound) 
	end

	def GetKsmps()
		 return CsoundModule.csoundGetKsmps(@csound) 
	end

	def GetNchnls()
		 return CsoundModule.csoundGetNchnls(@csound) 
	end

	def GetNchnlsInput()
		 return CsoundModule.csoundGetNchnlsInput(@csound) 
	end

	def GetCurrentTimeSamples()
		 return CsoundModule.csoundGetCurrentTimeSamples(@csound) 
	end

	def GetSizeOfMYFLT()
		 return CsoundModule.csoundGetSizeOfMYFLT() 
	end

	def SetHostData(hostData)
		 return CsoundModule.csoundSetHostData(hostData) 
	end

	def SetOption(option)
		 return CsoundModule.csoundSetOption(@csound, option) 
	end

	def SetParams(p)
		 return CsoundModule.csoundSetParams(@csound, p) 
	end

	def GetParams(p)
		 return CsoundModule.csoundGetParams(@csound, p) 
	end

	def GetDebug()
		 return CsoundModule.csoundGetDebug(@csound) 
	end

	def SetDebug(debug)
		 return CsoundModule.csoundSetDebug(debug) 
	end

	def SystemSr(val)
		 return CsoundModule.csoundSystemSr(@csound, val) 
	end

	def SetInput(name)
		 return CsoundModule.csoundSetInput(@csound, name) 
	end

	def SetMIDIInput(name)
		 return CsoundModule.csoundSetMIDIInput(@csound, name) 
	end

	def SetMIDIFileInput(name)
		 return CsoundModule.csoundSetMIDIFileInput(@csound, name) 
	end

	def SetMIDIOutput(name)
		 return CsoundModule.csoundSetMIDIOutput(@csound, name) 
	end

	def SetMIDIFileOutput(name)
		 return CsoundModule.csoundSetMIDIFileOutput(@csound, name) 
	end

	def SetRTAudioModule(rtmodule)
		 return CsoundModule.csoundSetRTAudioModule(@csound, rtmodule) 
	end

	def GetInputBufferSize()
		 return CsoundModule.csoundGetInputBufferSize(@csound) 
	end

	def GetOutputBufferSize()
		 return CsoundModule.csoundGetOutputBufferSize(@csound) 
	end

	def ClearSpin()
		 return CsoundModule.csoundClearSpin(@csound) 
	end

	def GetSpoutSample(frame, channel)
		 return CsoundModule.csoundGetSpoutSample(@csound, frame, channel) 
	end

	def SetRtcloseCallback(arg_void)
		 return CsoundModule.csoundSetRtcloseCallback(arg_void) 
	end

	def SetMIDIModule(rtmodule)
		 return CsoundModule.csoundSetMIDIModule(@csound, rtmodule) 
	end

	def ReadScore(str)
		 return CsoundModule.csoundReadScore(@csound, str) 
	end

	def ReadScoreAsync(str)
		 return CsoundModule.csoundReadScoreAsync(@csound, str) 
	end

	def GetScoreTime()
		 return CsoundModule.csoundGetScoreTime(@csound) 
	end

	def IsScorePending()
		 return CsoundModule.csoundIsScorePending(@csound) 
	end

	def SetScorePending(pending)
		 return CsoundModule.csoundSetScorePending(pending) 
	end

	def GetScoreOffsetSeconds()
		 return CsoundModule.csoundGetScoreOffsetSeconds(@csound) 
	end

	def SetScoreOffsetSeconds(time)
		 return CsoundModule.csoundSetScoreOffsetSeconds(time) 
	end

	def RewindScore()
		 return CsoundModule.csoundRewindScore(@csound) 
	end

	def ScoreSort(inFile, outFile)
		 return CsoundModule.csoundScoreSort(inFile, outFile) 
	end

	def Message(format)
		 return CsoundModule.csoundMessage(format) 
	end

	def GetMessageLevel()
		 return CsoundModule.csoundGetMessageLevel(@csound) 
	end

	def SetMessageLevel(messageLevel)
		 CsoundModule.csoundSetMessageLevel(messageLevel) 
	end

	def CreateMessageBuffer(toStdOut)
		 return CsoundModule.csoundCreateMessageBuffer(@csound, toStdOut) 
	end

	def GetFirstMessageAttr()
		 return CsoundModule.csoundGetFirstMessageAttr(@csound) 
	end

	def PopFirstMessage()
		 CsoundModule.csoundPopFirstMessage(@csound) 
	end

	def GetMessageCnt()
		 return CsoundModule.csoundGetMessageCnt(@csound) 
	end

	def DestroyMessageBuffer()
		 return CsoundModule.csoundDestroyMessageBuffer(@csound) 
	end

	def ListChannels(lst)
		 return CsoundModule.csoundListChannels(@csound,lst) 
	end

	def DeleteChannelList(lst)
		 return CsoundModule.csoundDeleteChannelList(lst) 
	end

	def GetChannelDatasize(name)
		 return CsoundModule.csoundGetChannelDatasize(@csound, name) 
	end

	def InputMessage(message)
		 return CsoundModule.csoundInputMessage(message) 
	end

	def InputMessageAsync(message)
		 return CsoundModule.csoundInputMessageAsync(message) 
	end

	def KeyPress(c)
		 return CsoundModule.csoundKeyPress(c) 
	end

	def TableLength(table)
		 return CsoundModule.csoundTableLength(table) 
	end

	def TableGet(table, index)
		 return CsoundModule.csoundTableGet(table, index) 
	end

	def TableSet(table, index, value)
		 return CsoundModule.csoundTableSet(table, index, value) 
	end

	def TableCopyOut(table, dest)
		 return CsoundModule.csoundTableCopyOut(@csound, table, dest) 
	end

	def TableCopyOutAsync(table, dest)
		 return CsoundModule.csoundTableCopyOutAsync(@csound, table, dest) 
	end

	def TableCopyIn(table, src)
		 return CsoundModule.csoundTableCopyIn(@csound, table, src) 
	end

	def TableCopyInAsync(table, src)
		 return CsoundModule.csoundTableCopyInAsync(@csound, table, src) 
	end

	def GetTable(tablePtr, tableNum)
		 return CsoundModule.csoundGetTable(tablePtr, tableNum) 
	end

	def GetTableArgs(argsPtr, tableNum)
		 return CsoundModule.csoundGetTableArgs(@csound, argsPtr, tableNum) 
	end

	def IsNamedGEN(num)
		 return CsoundModule.csoundIsNamedGEN(@csound, num) 
	end

	def GetNamedGEN(num, name, len)
		 return CsoundModule.csoundGetNamedGEN(@csound, num, name, len) 
	end

	def SetIsGraphable(isGraphable)
		 return CsoundModule.csoundSetIsGraphable(isGraphable) 
	end

	def NewOpcodeList(opcodelist)
		 return CsoundModule.csoundNewOpcodeList(opcodelist) 
	end

	def DisposeOpcodeList(opcodelist)
		 return CsoundModule.csoundDisposeOpcodeList(opcodelist) 
	end

	def SetYieldCallback(arg_int)
		 return CsoundModule.csoundSetYieldCallback(arg_int) 
	end

	def JoinThread(thread)
		 return CsoundModule.csoundJoinThread(thread) 
	end

	def WaitThreadLock(lock, milliseconds)
		 return CsoundModule.csoundWaitThreadLock(lock, milliseconds) 
	end

	def WaitThreadLockNoTimeout(lock)
		 return CsoundModule.csoundWaitThreadLockNoTimeout(lock) 
	end

	def NotifyThreadLock(lock)
		 return CsoundModule.csoundNotifyThreadLock(lock) 
	end

	def DestroyThreadLock(lock)
		 return CsoundModule.csoundDestroyThreadLock(lock) 
	end

	def LockMutex(mutex)
		 return CsoundModule.csoundLockMutex(mutex) 
	end

	def LockMutexNoWait(mutex)
		 return CsoundModule.csoundLockMutexNoWait(mutex) 
	end

	def UnlockMutex(mutex)
		 return CsoundModule.csoundUnlockMutex(mutex) 
	end

	def DestroyMutex(mutex)
		 return CsoundModule.csoundDestroyMutex(mutex) 
	end

	def DestroyBarrier(barrier)
		 return CsoundModule.csoundDestroyBarrier(barrier) 
	end

	def WaitBarrier(barrier)
		 return CsoundModule.csoundWaitBarrier(barrier) 
	end

	def CondWait(condVar, mutex)
		 return CsoundModule.csoundCondWait(condVar, mutex) 
	end

	def CondSignal(condVar)
		 return CsoundModule.csoundCondSignal(condVar) 
	end

	def Sleep(milliseconds)
		 return CsoundModule.csoundSleep(milliseconds) 
	end

	def SpinLockInit(spinlock)
		 return CsoundModule.csoundSpinLockInit(spinlock) 
	end

	def SpinLock(spinlock)
		 return CsoundModule.csoundSpinLock(spinlock) 
	end

	def SpinTryLock(spinlock)
		 return CsoundModule.csoundSpinTryLock(spinlock) 
	end

	def SpinUnLock(spinlock)
		 return CsoundModule.csoundSpinUnLock(spinlock) 
	end

	def RunCommand(argv, noWait)
		 return CsoundModule.csoundRunCommand(argv, noWait) 
	end

	def InitTimerStruct(arg_pointer)
		 return CsoundModule.csoundInitTimerStruct(arg_pointer) 
	end

	def GetRealTime(arg_pointer)
		 return CsoundModule.csoundGetRealTime(arg_pointer) 
	end

	def GetCPUTime(arg_pointer)
		 return CsoundModule.csoundGetCPUTime(arg_pointer) 
	end

	def GetRandomSeedFromTime()
		 return CsoundModule.csoundGetRandomSeedFromTime() 
	end

	def SetGlobalEnv(name, value)
		 return CsoundModule.csoundSetGlobalEnv(name, value) 
	end

	def DestroyGlobalVariable(name)
		 return CsoundModule.csoundDestroyGlobalVariable(name) 
	end

	def DeleteUtilityList(lst)
		 return CsoundModule.csoundDeleteUtilityList(lst) 
	end

	def RandMT(p)
		 return CsoundModule.csoundRandMT(p) 
	end

	def FlushCircularBuffer(p)
		 return CsoundModule.csoundFlushCircularBuffer(@csound, p) 
	end

	def DestroyCircularBuffer(circularbuffer)
		 return CsoundModule.csoundDestroyCircularBuffer(@csound, circularbuffer) 
	end

	def OpenLibrary(library, libraryPath)
		 return CsoundModule.csoundOpenLibrary(library, libraryPath) 
	end

	def CloseLibrary(library)
		 return CsoundModule.csoundCloseLibrary(library) 
	end

	#Handwritten

	def SetControlChannel(channel_name, value)
		CsoundModule.csoundSetControlChannel(@csound, channel_name, value)
	end

	def GetControlChannel(channel_name)
	  return CsoundModule.csoundGetControlChannel(@csound, channel_name, nil)
	end

	def SetOutputChannelCallback(cbk)
	  # Is this function destroyed someday ?
	  c_cbk = FFI::Function.new(:void, [:pointer,:string,:pointer,CS_TYPE.by_ref]) do |csound,channel_name,valueptr, channel_type|
		if(channel_type[:varTypeName] == "k") then 
		  cbk(channel_name, valueptr.read(FFI::Type::DOUBLE), channel_type[:varTypeName])
		elsif(channel_type[:varTypeName] == "S") then 
		  cbk(channel_name, valueptr.read_string, channel_type[:varTypeName])
		end
	  end
	  CsoundModule.csoundSetOutputChannelCallback(@csound, c_cbk)
	end

	def SetInputChannelCallback(cbk)
	  c_cbk = FFI::Function.new(:void, [:pointer,:string,:pointer,CS_TYPE.by_ref]) do |csound,channel_name,valueptr, channel_type|
	  end
	  CsoundModule.csoundSetInputChannelCallback(@csound, c_cbk)
	end

	def GetFirstMessage()
		return CsoundModule.csoundGetFirstMessage(@csound)
	end

	def GetSr
		return CsoundModule.csoundGetSr(@csound)
	end

	def GetSpout
		return CsoundModule.csoundGetSpout(@csound)
	end

	def GetSpoutSample(frame, channel)
		return csoundGetSpoutSample(@csound, frame, channel)
	end

	def GetSpin
		return CsoundModule.csoundGetSpin(@csound)
	end

	def ClearSpin
		CsoundModule.csoundClearSpin(@csound)
	end

	def AddSpinSample(frame, channel, sample)
		CsoundModule.csoundAddSpinSample(@csound,frame,channel,sample)
	end

	def SetSpinSample(frame, channel, sample)
		CsoundModule.csoundSetSpinSample(@csound, frame, channel, sample)
	end

	def GetEnv(name)
		return CsoundModule.csoundGetEnv(@csound,name)
	end

	def CreateGlobalVariable(name, nbytes)
		return CsoundModule.csoundCreateGlobalVariable(@csound, name, nbytes)
	end

	def QueryGlobalVariable(name)
		return CsoundModule.csoundQueryGlobalVariable(@csound, name)
	end

	def QueryGlobalVariableNoCheck(name)
		return CsoundModule.csoundQueryGlobalVariableNoCheck(@csound, name)
	end
	
	def RunUtility(name, argc, argv)
		return CsoundModule.csoundRunUtility(@csound, argc, argv)
	end

	def ListUtilities
		return CsoundModule.csoundListUtilities(@csound)
	end

	def GetUtilityDescription(name)
		return CsoundModule.csoundGetUtilityDescription(@csound,name)
	end

	def CreateCircularBuffer(numelem, elemsize)
		return CsoundModule.csoundCreateCircularBuffer(@csound,numelem,elemsize)
	end

	def ReadCircularBuffer(buffer, out, items)
		return CsoundModule.csoundReadCircularBuffer(@csound,buffer,out,items)
	end

	def PeekCircularBuffer(buffer, out, items)
		return CsoundModule.csoundPeekCircularBuffer(@csound, buffer, out, items)
	end

	def WriteCirularBuffer(p,inp,items)
		return CsoundModule.csoundWriteCircularBuffer(@csound,p,inp,items)
	end
end
