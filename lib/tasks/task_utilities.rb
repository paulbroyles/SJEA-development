module TaskUtilities

	def cmd_line(str)
		puts str
		puts `#{str}`
	end

	def start_line(msg)
		puts "=== #{msg}"
		puts "=============================================================================="
		return Time.now
	end

	def finish_line(start_time)
		duration = Time.now-start_time
		if duration >= 60
			str = "Finished in #{"%.2f" % (duration/60)} minutes."
		else
			str = "Finished in #{"%.2f" % duration} seconds."
		end
		puts "=== #{str}"
		puts "=============================================================================="
	end

	def file_exists(path)
		return File.file?(path)
	end

  def delete_dir(dname)
    begin
      FileUtils.rm_rf(dname)
    rescue
    end
  end

	def delete_file(fname)
		begin
			File.delete(fname)
		rescue
		end
	end

  def copy_file(sfname, dfname)
    begin
      FileUtils.copy(sfname, dfname)
    rescue
    end
  end

  def make_dir(dname)
    begin
      Dir.mkdir(dname)
    rescue
    end
  end

  def append_to_file(fname, line)
    begin
       File.open( fname, "a") {|f| f << line}
    rescue
    end
  end

  def filename_sort_helper( aname, bname )

    anumS = aname.split( "/" )[ 2 ].slice( 3..-1 )
    anum = anumS.to_f
    bnumS = bname.split( "/" )[ 2 ].slice( 3..-1 )
    bnum = bnumS.to_f

    # standard spaceship op behavior until they are ==. Then sort by length.
    if anum < bnum
      return -1
    elsif anum > bnum
      return 1
    else
      if anumS.length < bnumS.length
        return -1
      elsif anumS.length > bnumS.length
        return 1
      else
        return 0
      end
    end
  end

  def transcription_file_list( )
    return %w{ SJA SJC SJD SJE SJEx SJL SJP SJU SJV }
  end

  def manuscript_view_list( )
    return %w{ MS-alltags MS-critical MS-diplomatic MS-scribal }
  end

  def description_file_list( )
    #return [ "A Description", "C Description", "D Description", "E Description", "Ex Description", "L Description", "P Description", "U Description", "V Description" ]
    return [ "ADescription", "LDescription" ]
  end

  def xsl_transform_cmd( xmlfile, xslfile )
    return "java -jar tools/saxonhe-9-3-0-5j/saxon9he.jar -s:#{xmlfile} -xsl:#{xslfile}"
  end

end
