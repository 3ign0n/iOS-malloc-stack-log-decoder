#!/usr/bin/env ruby

class MallocStackLogEntry
  attr_reader :size, :flag, :stack_identifier, :address_disguise

  def initialize(no, flag, stack_identifier, address_disguise, argument)
  	@no = no
  	@flag = flag
  	@stack_identifier = stack_identifier
  	@addr_disguise = address_disguise
  	@size = argument
  end

  def address
  	# 0x00005555 is magic number
  	# see STACK_LOGGING_DISGUISE macro in Apple Libc
  	# http://opensource.apple.com/source/Libc/Libc-763.12/gen/stack_logging.h
  	return @addr_disguise ^ 0x00005555
  end

  def type
  	return "ALLOC" if @flag == 2
  	return "FREE " if @flag == 4
  	return "OTHER"
  end

  def to_s
  	#return sprintf("[%0#{8}d]: ", @no) + self.type + ", stackid=" + sprintf("0x%0#{14}X", @stack_identifier) + ", address=" + sprintf("0x%0#{8}X", self.address) + ", size=" + @size.to_s
  	print sprintf("[%0#{8}d]: ", @no) + self.type
  	print ", stackid=" + sprintf("0x%0#{14}X", @stack_identifier)
  	print ", address=" + sprintf("0x%0#{8}X", self.address)
  	print ", size=" + @size.to_s + "\n"
  end

end

# hack structure of stack logging binary in iOS devices
# see stack_logging_index_event32 in Apple Libc 
# http://opensource.apple.com/source/Libc/Libc-763.12/gen/stack_logging_disk.c
def decode_malloc_stack_log_one_recode(fio, no)
	tmpbin = fio.read(4)
	return nil if tmpbin == nil
	argument = tmpbin.unpack("V*")[0]

	tmpbin = fio.read(4)
	return nil if tmpbin == nil
	addr_disguise = tmpbin.unpack("V*")[0]

	tmpbin = fio.read(4)
	return nil if tmpbin == nil
	offset_and_flags_l = tmpbin.unpack("V*")[0]

	tmpbin = fio.read(4)
	return nil if tmpbin == nil
	offset_and_flags_h = tmpbin.unpack("V*")[0]
	flag = (offset_and_flags_h & 0xff000000) >> 24
	stack_id = ((offset_and_flags_h & 0x00FFFFFF)<< 32) | offset_and_flags_l

	return MallocStackLogEntry.new no, flag, stack_id, addr_disguise, argument
end

def decode_malloc_stack_log(fio)
  begin
  	n = 0
  	recode = decode_malloc_stack_log_one_recode fio, n
  	while recode != nil
  		#print recode.to_s + "\n"
  		recode.to_s
  		n = n +1
  		recode = decode_malloc_stack_log_one_recode fio, n
  	end
  rescue EOFError, TypeError
  end
end

if __FILE__ == $0
  if ARGV.length > 1
  	print "ERROR: too many arguments\n"
  	show_help
  	exit 1
  elsif ARGV.length == 1
  	file_path = ARGV.shift
  	fio = File.open(file_path, File::RDONLY)
  else
  	fio = $stdin
  end

  decode_malloc_stack_log fio

  fio.close
end

