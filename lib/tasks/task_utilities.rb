require "xml"
require "rexml/document"

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
    return %w{ alltags critical diplomatic scribal }
  end

  def description_file_list( )
    return %w{ ADescription CDescription DDescription EDescription ExDescription LDescription PDescription UDescription VDescription }
  end

  def copyright_text_list( )

     return [ "&#169;THE BRITISH LIBRARY BOARD.  ALL RIGHTS RESERVED.",
              "&#169;THE BRITISH LIBRARY BOARD.  ALL RIGHTS RESERVED.",
              "Reproduced by permission of the Trustees of Lambeth Palace Library",
              "Reproduced by permission of the Trustees of the Huntington Library",
              "Reproduced by permission of the Devon Record Office",
              "Reproduced by permission of the Bodleian Library, University of Oxford Bodleian Library, MS Laud Misc. 656, Fol. _FOLIONAME_",
              "Reproduced by permission of Princeton University Library",
              "Reproduced by kind permission of the Syndics of Cambridge University Library",
              "&#169;THE BRITISH LIBRARY BOARD.  ALL RIGHTS RESERVED." ]
  end


  def transcript_title_list()
    return [ "British Library, MS Additional 31042 (A)",
             "British Library, MS Cotton Caligula A.ii, part I (C)",
             "Lambeth Palace Library, MS 491 (D)",
             "Huntington Library, MS HM 128 (E)",
             "Devon Record Office, Deposit 2507 (Ex)",
             "Bodleian Library, MS Laud Misc. 656 (L)",
             "Princeton University Library, MS Taylor Medieval 11 (P)",
             "Cambridge University Library, MS Mm.v.14 (U)",
             "British Library, MS Cotton Vespasian E.xvi (V)" ]
  end

  def xsl_transform_cmd( xmlfile, xslfile )
    return "java -jar tools/saxonhe-9-3-0-5j/saxon9he.jar -s:#{xmlfile} -xsl:#{xslfile}"
  end

  # Process any node contained in a line. Written by PAB to replace old logic.
	# This is recursive, letting us use a single set of rules for how types of
	# elements shoudl be treated.
	def processNodeInLine( node, hl )
		if ( node.kind_of? REXML::Text ) == true
			return node.value( )
		else
			content = ""

			case node.name

			when "hi", "expan", "add", "choice", "reg", "corr", "damage", "unclear", "seg"
				node.each_child( ) do |child|
					content << processNodeInLine(child, hl)
				end

			when "supplied"
				content << "["
				node.each_child( ) do |child|
					content << processNodeInLine(child, hl)
				end
				content << "]"

			when "gap"
			 # Show blanks with empty characters. See the XSLT
			 # for how this works. PAB.
			 if node.attributes["unit"] == "chars"
				 # if the gap length is specified in characters
				 times = 1 # Initialize the variable for the length of the gap
									 # at 1, then overwrite as appropriate
				 if node.attributes["quantity"] != nil
					 times = node.attributes["quantity"]
				 elsif node.attributes["atLeast"] != nil && node.attributes["atMost"] != nil
					 times = ((node.attributes["atLeast"].to_f + node.attributes["atMost"].to_f) / 2).round
				 elsif node.attributes["atLeast"]
					 times = node.attributes["atLeast"]
				 elsif node.attributes["atMost"]
					 times = node.attributes["atMost"]
				 end

				 content << "?" * times

			 elsif node.attributes["extent"] == "rest of line"
				 # if the rest of the line is omitted, insert an ellipsis
				 content << "..."
			 end

		 when "note", "del", "orig", "abbr", "sic", "g", "addSpan", "anchor", "space"
				# ignore these

			else
				puts "UNPROCESSED TAG #{node.name} #{hl}"
			end

		return content
	end
end

  def processLineChildren( line )

      content = ""
      hl = line.attributes["n"]

      line.each_child() do |child|
				content << processNodeInLine( child, hl )
      end

      return content

  end

  def processLineNode( node, folio, linelist )

     loc_line = node.attributes["xml:id"]
     hl_line = node.attributes["n"]
     content = processLineChildren( node )

     # if we have any content, clean it up and store it
     if content.empty? == false
        # remove duplicate whitespace
        content = content.gsub(/\n/, "" ).squeeze(" ").gsub( /^ /, "" )

        #puts "#{folio} : #{hl} #{content}"
        linelist[ linelist.size ] = { :pageimg => folio, :loc_line => loc_line, :hl_line => hl_line, :content => content }
     else
        puts "** EMPTY LINE: #{hl_line} **"
     end

  end

	# wrapper function to contain all loading behavior for a specific file. Calls
	# the recursive function that processes structural elements and prints the
	# report on what was processed.
	def processDoc( doc, linelist )
		body = REXML::XPath.first(doc, '//text/body')
		pages, lines, folio = processStructure( body, linelist, 0, 0, "UNKNOWN" )
		puts "Processed #{pages} pages, #{lines} lines"
	end

	# recursive function that loop through multiple layers of structural elements
	# until reaching the line elements for processing. Returns counts of the
	# numbers of pages and lines, which are used to increment the counts at higher
	# structural levels, and ultimately passed to the calling function.
	def processStructure ( el, linelist, pages, lines, folio )
		el.each_element() do | child |

			case child.name

			when "milestone"
				if child.attributes["unit"] == "fol."
					folio = child.attributes["entity"]
					pages += 1
				end

			when "div", "div1", "div2", "div3", "div4", "div5", "div6", "div7", "lg", "add"
				pages, lines, folio = processStructure( child, linelist, pages, lines, folio )

			when "l"
				processLineNode( child, folio, linelist )
				lines +=1

			when "lb", "cb", "fw", "marginalia", "head", "trailer"
				# These are expected elements that have no bearing on comparison or
				# search, so ignore them.

			else
				puts "UNPROCESSED TAG in processStructure #{child.name}"
			end

		end

		return pages, lines, folio

	end

  def load_transcription_from_file( xmlfile )

     linelist = []

     puts "Processing #{xmlfile}..."

     xml = File.read( xmlfile )
     doc = REXML::Document.new( xml )

		 processDoc( doc, linelist )

     return linelist

  end

  def load_comparison_from_file( xmlfile )

    result = Array.new
    linecount = 0
    file = File.new( xmlfile, "r")
    while ( json = file.gets )

       #puts "[#{json.gsub(/\n/, "" )}]"
       parsed_json = ActiveSupport::JSON.decode( json.strip )
       result[ linecount] = parsed_json
       linecount += 1

    end
    file.close
    return result

  end

  def load_description_from_file( xmlfile )

    result = []
    linecount = 0
    xmldoc = XML::Reader.file( xmlfile, :options => XML::Parser::Options::NOBLANKS | XML::Parser::Options::PEDANTIC )

    while xmldoc.read
       unless xmldoc.node_type == XML::Reader::TYPE_END_ELEMENT

          case xmldoc.name
            when "author",
                 "bibl",
                 "binding",
                 "collation",
                 "condition",
                 "contents",
                 "country",
                 "date",
                 "deconote",
                 "edition",
                 "editor",
                 "extent",
                 "foliation",
                 "format",
                 "graphic",
                 "hi",
                 "idno",
                 "item",
                 "layout",
                 "locus",
                 "measure",
                 "origDate",
                 "origPlace",
                 "p",
                 "persName",
                 "placeName",
                 "provenance",
                 "pubPlace",
                 "publisher",
                 "ref",
                 "repository",
                 "settlement",
                 "summary",
                 "support",
                 "title"

               content = xmldoc.node.content
               if content.empty? == false
                  result[ linecount] = content
                  linecount += 1

               end
          end
       end
    end

    xmldoc.close
    #puts "processed #{pagecount} pages and #{linecount} lines"

    return result

  end

  def load_annotations_from_file( xmlfile )

    pending_page_content = ""
    page_image_file = ""
    result = []
    pagecount = 0
    linecount = 0

    xmldoc = XML::Reader.file( xmlfile, :options => XML::Parser::Options::NOBLANKS | XML::Parser::Options::PEDANTIC )

    while xmldoc.read
       unless xmldoc.node_type == XML::Reader::TYPE_END_ELEMENT

          case xmldoc.name

             # the initial tag for the start of a new page
             when "milestone"

               # always flush any pending data...
               if pending_page_content.empty? == false
                   abort( "page_image_file empty!") unless page_image_file.empty? == false

                   result[ pagecount ] = { :pageimg => page_image_file, :content => pending_page_content }
                   #puts "page #{pagecount + 1}: img [#{page_image_file}], note [#{pending_page_content}]"
                   pending_page_content = ""
                   pagecount += 1
               end

               page_image_file = xmldoc[ "entity" ]

            when "note"

                content = xmldoc.read_string
                # sometimes there is a <note> tag with no content so ignore those
                if content.empty? == false
                  pending_page_content << content << " "
                  linecount += 1
                end

           end
        end
     end

     # gets any remaining content that has not already been processed
     if pending_page_content.empty? == false
       abort( "page_image_file empty!") unless page_image_file.empty? == false
        result[ pagecount ] = { :pageimg => page_image_file, :content => pending_page_content }
        #puts "page #{pagecount + 1}: img [#{page_image_file}], note [#{pending_page_content}]"
        pagecount += 1
     end

     xmldoc.close
     #puts "processed #{linecount} notes in #{pagecount} page(s)"

     return result

  end

end
