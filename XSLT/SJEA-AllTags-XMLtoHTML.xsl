<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:idhmc="http://idhmc.tamu.edu/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="#default html a fo rng tei teix" version="2.0">

    <!-- *************************************************************************
     This XSLT was written by Matthew Christy of the TAMU IDHMC for Tim
     Stinson's "Seige of Jerusalem" project. It is an online publication
     of multiple copies of "The Seige of Jerusalem" including transcriptions
     in various formats (Scribal, Critical, Diplomatic, and All) and
     page images in jpeg and tiff formats.

     4/27/2012: First draft
     
     Modifications were made by Paul Broyles, CLIR Postdoctoral Fellow for
     Data Curation in Medieval Studies, North Carolina State University (pab).
    -->

    <!--mjc: Variables-->
    <!--     =========-->
    <xsl:variable name="xmlpath">
        <xsl:value-of>xml/</xsl:value-of>
    </xsl:variable>
    <xsl:variable name="imgpath">
        <xsl:value-of>images/</xsl:value-of>
    </xsl:variable>
    <xsl:variable name="csspath">
        <xsl:value-of>stylesheets/</xsl:value-of>
    </xsl:variable>


    <!--Define tags that need whitespace stripped or preserved-->
    <xsl:strip-space elements="" />
    <xsl:preserve-space elements="" />
    
        
        
    <!--mjc: HTML Output-->
    <!--     ===========-->
    <xsl:output method="html" indent="no" name="html" normalization-form="none"/>


    <!--mjc: XML Input-->
    <!--     =========-->
    <xsl:template match="SJEA/part">
        <xsl:apply-templates select="document(@code)/tei:TEI">
            <xsl:with-param name="id" select="@code" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    
    <!--************************-->
    <!--mjc: tei:TEI template   -->
    <!--     =======            -->
    <!--     determines what HTML files to produce and what to name them-->
    <!--************************-->
    <xsl:template match="tei:TEI">
        <xsl:param name="id" tunnel="yes"/>

        <!--mjc: the path/filename to output to-->
        <xsl:variable name="idno">
            <xsl:value-of
                select="substring-after(substring-before($id, '.xml'), concat($xmlpath, 'SJ'))"
            />
        </xsl:variable>

        <!--mjc: get the path of the file for this output-->
        <xsl:variable name="filename">
            <xsl:value-of
                select="concat('MS', $idno)"
            > </xsl:value-of>
        </xsl:variable>


        <!--mjc: ALLTAGS                                    -->
        <!--     =======                                    -->
        <!--     Generaate the AllTags output               -->
        <xsl:result-document href="{concat($filename, '-alltags.html')}" format="html">
            <xsl:call-template name="generateHTML">
                <xsl:with-param name="view" select="string('alltags')" tunnel="yes"/>
                <xsl:with-param name="idno" select="$idno" tunnel="yes"/>
            </xsl:call-template>
        </xsl:result-document>
        
        <!--mjc: CRITICAL                                   -->
        <!--     ========                                   -->
        <!--     Generaate the Critical output              -->
        <xsl:result-document href="{concat($filename, '-critical.html')}" format="html">
            <xsl:call-template name="generateHTML">
                <xsl:with-param name="view" select="string('critical')" tunnel="yes"/>
                <xsl:with-param name="idno" select="$idno" tunnel="yes"/>
            </xsl:call-template>
        </xsl:result-document>
        
        <!--mjc: SCRIBAL                                    -->
        <!--     =======                                    -->
        <!--     Generaate the Scribal output               -->
        <xsl:result-document href="{concat($filename, '-scribal.html')}" format="html">
            <xsl:call-template name="generateHTML">
                <xsl:with-param name="view" select="string('scribal')" tunnel="yes"/>
                <xsl:with-param name="idno" select="$idno" tunnel="yes"/>
            </xsl:call-template>
        </xsl:result-document>
        
        <!--mjc: DIPLOMATIC                                 -->
        <!--     ==========                                 -->
        <!--     Generaate the Diplomatic output            -->
        <xsl:result-document href="{concat($filename, '-diplomatic.html')}" format="html">
            <xsl:call-template name="generateHTML">
                <xsl:with-param name="view" select="string('diplomatic')" tunnel="yes"/>
                <xsl:with-param name="idno" select="$idno" tunnel="yes"/>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>



    <!--**************************-->
    <!--mjc: generateHTML template-->
    <!--     =====================-->
    <!--     create the HTML structure for the page -->
    <!--     and generate other page elements       -->
    <!-- param: view (a string that indicates which -->
    <!--        view is being built                 -->
    <!--**************************-->
    <xsl:template name="generateHTML">
        <xsl:param name="id" tunnel="yes"/>
        <xsl:param name="view" tunnel="yes"/>
        <xsl:param name="idno" tunnel="yes"/>
        
        <xsl:variable name="pagetitle">
            <xsl:call-template name="generateTitle"/>
        </xsl:variable>
        
        <!--mjc: layout the main structure of the HTML output doc -->
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <!-- Manuscript pages are always injected via Ajax into manuscript.html, so including
                    these lines causes CSS and JS to be parsed a second time. -->
                <!--<link href="/stylesheets/manuscript.css" rel="stylesheet" type="text/css"/>
                <link href="/stylesheets/sjea-common.css" media="screen" rel="stylesheet" type="text/css" />
                <link href="/stylesheets/colorbox.css" media="screen" rel="stylesheet" type="text/css" />

                <script src="/javascripts/jquery-1.7.2.min.js" type="text/javascript"></script>
                <script src="/javascripts/jquery.tools.min.js" type="text/javascript"></script>
                <script src="/javascripts/jquery.blockUI.js" type="text/javascript"></script>
                <script src="/javascripts/jquery.colorbox-min.js" type="text/javascript"></script>
                <script src="/javascripts/jquery.qtip-1.0.0-rc3.min.js" type="text/javascript"></script>
                <script src="/javascripts/tooltips.js" type="text/javascript"></script>-->

                <title>
                    <xsl:value-of select="concat($pagetitle, '-', $view)"/>
                </title>
                
                <!--mjc: add the teiHeader info -->
                <xsl:comment>
                    <xsl:text>XML source info</xsl:text>
                    <xsl:copy-of select="//tei:teiHeader"/>
                </xsl:comment>
            </head>
            
            <body class="contentArea">
                <h1><xsl:value-of select="concat(//tei:sourceDesc//tei:repository, ', MS ', //tei:sourceDesc//tei:idno, ' (', $idno, ')')"/></h1>

                <xsl:call-template name="processBody"/>
            </body>
        </html>
    </xsl:template>
    

    <!--***************************-->
    <!--mjc: generateTitle template-->
    <!--     =============         -->
    <!--     create a <head>/<title>                                          -->
    <!--     use the value in teiHeader/fileDesc/titleStmt/title[@type='main']-->
    <!--***************************-->
    <xsl:template name="generateTitle">
        <xsl:param name="id" tunnel="yes"/>
        <xsl:param name="idno" tunnel="yes"/>
        
        <xsl:variable name="repos">
            <xsl:value-of select="//tei:sourceDesc//tei:repository"/>
        </xsl:variable>
        
        <xsl:value-of select="concat($repos, ', MS ', $idno)"/>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: copyNodes template-->
    <!--     =========         -->
    <!--mjc: format the body of the file-->
    <!--*************************-->
    <xsl:template name="copyNodes">
        <xsl:param name="name"/>
        
        <xsl:for-each select="$name">
        <xsl:choose>
            <xsl:when test="self::comment()">
                ***COMMMENT***
            </xsl:when>
            
            <xsl:when test="./descendant::*">
                +++DESCENDENT***
                <xsl:copy>
                    
                    <xsl:call-template name="copyNodes">
                        <xsl:with-param name="name" select="./descendant::node()[1]"/>
                    </xsl:call-template>
                </xsl:copy>
                ---/DESENDENT***
            </xsl:when>
            
            <xsl:when test="./following-sibling::*">
                +++SIBLING***
                <xsl:copy-of select="."/>
                    
                
                <xsl:call-template name="copyNodes">
                    <xsl:with-param name="name" select="./following-sibling::node()[1]"/>
                </xsl:call-template>
                ---/SIBLING***
            </xsl:when>
            
            <xsl:otherwise>
                ***SELF***
                <xsl:copy-of select="."/>
                    
            </xsl:otherwise>
        </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: processBody template-->
    <!--     ===========         -->
    <!--mjc: format the body of the file-->
    <!--*************************-->
    <xsl:template name="processBody">
        <!-- main text -->
        <xsl:for-each select="//tei:text/tei:body/tei:div">
            <div>
                <xsl:apply-templates/>
            </div>
        </xsl:for-each>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: convertNum template-->
    <!--     ==========         -->
    <!--mjc: convert a number to the word equivalent-->
    <!--*************************-->
    <xsl:template name="convertNum">
        <xsl:param name="num"/>
        
        <xsl:choose>
            <xsl:when test="$num=1">
                One
            </xsl:when>
            <xsl:when test="$num=2">
                Two
            </xsl:when>
            <xsl:when test="$num=3">
                Three
            </xsl:when>
            <xsl:when test="$num=4">
                Four
            </xsl:when>
            <xsl:when test="$num=5">
                Five
            </xsl:when>
            <xsl:when test="$num=6">
                Six
            </xsl:when>
            <xsl:when test="$num=7">
                Seven
            </xsl:when>
            <xsl:when test="$num=8">
                Eight
            </xsl:when>
            <xsl:when test="$num=9">
                Nine
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc/pab: div template for passus -->
    <!--     ====         -->
    <!--mjc/pab: create passus headings -->
    <!--     based on view types.                       -->
    <!--*************************-->
    <xsl:template match="tei:div[@type='passus']">
        <xsl:param name="view" tunnel="yes"/>
        
        <div>
            <xsl:choose>
                <xsl:when test="$view='critical'">
                    <xsl:variable name="numW">
                        <xsl:call-template name="convertNum">
                            <xsl:with-param name="num" select="number(@n)"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <h2 class='passus-center'>Passus <xsl:value-of select="$numW"/></h2>
                    <xsl:apply-templates/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: head template-->
    <!--     ====         -->
    <!--mjc: turn <head> into <div> and create headings -->
    <!--     based on view types.                       -->
    <!--mdavis edited to handle marginalia in the head section 07-02-2015 -->
    <!--*************************-->
    <xsl:template match="tei:head">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:if test="$view!='critical'">
            <xsl:choose>
                <xsl:when test="@rend">
                    <h2>
                        <div class="passus-{substring-after(substring-before(@rend, ')'), '(')}">
                            <xsl:call-template name="generateMarginalia">
                                <xsl:with-param name="marginals" select="key('marginal',generate-id())"/>
                            </xsl:call-template>
                            <xsl:apply-templates/>
                        </div>
                    </h2>
                </xsl:when>
                
                <xsl:when test="@place">
                    <h2>
                        <div class="passus-{@place}">
                            <xsl:call-template name="generateMarginalia">
                                <xsl:with-param name="marginals" select="key('marginal',generate-id())"/>
                            </xsl:call-template>
                            <xsl:apply-templates/>
                        </div>
                    </h2>
                </xsl:when>
                
                <xsl:otherwise>
                    <h2>
                        <div class="passus">
                            <xsl:call-template name="generateMarginalia">
                                <xsl:with-param name="marginals" select="key('marginal',generate-id())"/>
                            </xsl:call-template>
                            <xsl:apply-templates/>
                        </div>
                    </h2>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:if>
    </xsl:template>
    
    
<!--    <!-\-*************************-\->
    <!-\-mjc: fw template-\->
    <!-\-     ==         -\->
    <!-\-mjc: for now let's ignore running headers.      -\->
    <!-\-     This may change as the layout is completed.-\->
    <!-\-*************************-\->
    <xsl:template match="tei:fw">
        <xsl:if test="@type='tunningHead'"/>
    </xsl:template>-->
    
    
    <!--*************************-->
    <!--mjc: milestone template-->
    <!--     =========         -->
    <!--mjc: turn <milestone>s into links to page images.-->
    <!--     img names given in @entity.                 -->
    <!--     path to imgs is "./MS <x> jpeg files".      -->
    <!--*************************-->
    <xsl:template match="tei:pb">
        <xsl:param name="id" tunnel="yes"/>
        
        <!--mjc: for formatting, put a <br/> before every <milestone>   -->
        <xsl:value-of disable-output-escaping="yes">&lt;br /&gt;</xsl:value-of>
        
        <xsl:variable name="imgbase" select="substring-before(@facs, '.jpg')"/>
        
        <xsl:variable name="imgName">
            <xsl:value-of select="concat($imgpath, $imgbase, '-thumbnail.jpg')"/>
        </xsl:variable>
        
        <!--mjc: if the <milestone> is immediately followed by a <marginalia>   -->
        <!--      with @place='top...' then put a <span> here for the text      -->
        <!--<xsl:if test="name(./following-sibling::*[1])='marginalia'">
            <xsl:variable name="pos" select="substring(./following-sibling::*[1]/@place, 1, 3)"/>
            
            <xsl:if test="$pos='top'">
                <xsl:call-template name="generateMarginalia">
                    <xsl:with-param name="margin" select="./following-sibling::tei:marginalia[1]"/>
                </xsl:call-template>
<!-\-                <!-\\-mjc: tell parser not to turn <br/> into <br></br>-\\->
                <xsl:value-of disable-output-escaping="yes">&lt;br /&gt;</xsl:value-of>-\->
            </xsl:if>
        </xsl:if>-->
        
        <!--dg: create <img> tags instead of <a> tags for the images. This shows the manuscript page -->
        <!--    as a thumbnail and matches the wireframes we have provided Tim for review.           -->
        <!--mjc:add a div around the img in order to add a coption div as well                       -->
        <div id="{@entity}" class="imageDiv">
            <div class="img">
                <a class="imglightbox" href="{concat('/',concat($imgbase, '-lb.html'))}">
                    <img src='{$imgName}' class="image"></img>
                </a>
            </div>
            <div class="caption">
                <xsl:value-of select="$imgbase"/>
            </div>
        </div>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: l template-->
    <!--     =         -->
    <!--mjc: format the lines (<l>s) of the file-->
    <!--*************************-->
    <xsl:template match="tei:l">
        <xsl:param name="id" tunnel="yes"/>
        <xsl:param name="view" tunnel="yes"/>
        <xsl:param name="idno" tunnel="yes"/>
        
        <xsl:variable name="manLine" select="substring-after(@xml:id, '.')"/>
        <xsl:variable name="HLLine" as="xs:double" select="number(substring-after(@n, '.'))"/>

        <!--mjc: display every forth line number-->
        <xsl:if test="(number($manLine) mod 4) = 0">
            <span class="lineMarker">
                <xsl:value-of select="concat($idno, ' ', number($manLine))"/>
                <xsl:if test="$view = 'critical' or $view = 'alltags'">
                    <a href="{concat('/comparison.html?comparison=HL.', substring-after(@n, '.'))}">
                        <xsl:value-of select="concat(' (HL ', $HLLine, ')')"/>
                    </a>
                </xsl:if>
            </span>
        </xsl:if>
        
        <!-- an HL placeholder -->
        <xsl:if test="(number($manLine) mod 4) != 0">
            <xsl:if test="$view = 'critical' or $view = 'alltags'">
                <span class="lineMarker">
                    <a href="{concat('/comparison.html?comparison=HL.', substring-after(@n, '.'))}">
                        <xsl:value-of select="concat('', '*')"/>
                    </a>
                </span>
            </xsl:if>
        </xsl:if>
        
        <!--mjc: if the line is followed by a <marginalia> with @place of left or right,    -->
        <!--     then display it with this line.                                            -->
        <!--     if @place is bottom then display it on another line                        -->
        <!--pab: updated to handle <fw> on the same principles as <marginalia>.             -->
        <!--<xsl:choose>
            
            <xsl:when test="name(./following-sibling::*[1])=('marginalia', 'fw')">
                <xsl:variable name="pos" select="substring(./following-sibling::*[1]/attribute::place, 1, 3)"/>
                
                <xsl:choose>
                    <xsl:when test="$pos='top' or $pos='bot'">
                        <div class="line" id="{@xml:id}">
                            <xsl:apply-templates/>
                        </div>
                        <!-\-mjc: tell parser not to turn <br/> into <br></br>-\->
                        <!-\-<xsl:value-of disable-output-escaping="yes">&lt;br /&gt;</xsl:value-of>-\->
                        
                        <xsl:call-template name="generateMarginalia">
                            <xsl:with-param name="margin" select="./following-sibling::tei:*[1][name(.) = ('marginalia', 'fw')]"/>
                        </xsl:call-template>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <div class="line" id="{@xml:id}">
                            <xsl:apply-templates/>
                            <xsl:call-template name="generateMarginalia">
                                <xsl:with-param name="margin" select="./following-sibling::tei:*[1][name(.) = ('marginalia', 'fw')]"/>
                            </xsl:call-template>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:when>
            
            <xsl:otherwise>
                <div class="line" id="{@xml:id}">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>-->
        
        <div class="line" id="{@xml:id}">
            <xsl:call-template name="generateMarginalia">
                <xsl:with-param name="marginals" select="key('marginal',generate-id())"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </div>
        
        <!--mjc: tell parser not to turn <br/> into <br></br>-->
        <!--<xsl:value-of disable-output-escaping="yes">&lt;br /&gt;</xsl:value-of>-->
    </xsl:template>
    
    <!--*************************-->
    <!--pab: lb template-->
    <!--     ===         -->
    <!--lb: insert a line break where <lb> element      -->
    <!--     occurs                                     -->
    <!--*************************-->
    <xsl:template match="tei:lb">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:value-of disable-output-escaping="yes">&lt;br /&gt;</xsl:value-of>
    </xsl:template>
    
    <!--*************************-->
    <!--mjc: seg template-->
    <!--     ===         -->
    <!--mjc: format the <seg> tags. there are two types -->
    <!--     we are interested in:                      -->
    <!--     - @type=bverse : add several pre-spaces in -->
    <!--        the critical view                       -->
    <!--     - @type=punct : for medial punctuation     -->
    <!--*************************-->
    <xsl:template match="tei:seg">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when test="@type='bverse' and $view='critical'">
                <xsl:choose>
                    <!--if there's any medial punct, then we don't want to add any extra spaces -->
                    <xsl:when test="//tei:g/@ref='#puncelev' or //tei:seg/@type='punct'">
                        <xsl:choose>
                            <xsl:when test="preceding-sibling::tei:g[1] or preceding-sibling::tei:seg[1]/@type='punct'">
                                <xsl:apply-templates/>
                            </xsl:when>
                            
                            <xsl:otherwise>
                                    <xsl:apply-templates/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <span class="bverse">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="@type = 'shadowHyphen'">
                <xsl:choose>
                    <xsl:when test="$view = 'critical'"/>
                    
                    <xsl:when test="$view = 'diplomatic'">
                        <xsl:value-of xml:space="preserve"> </xsl:value-of>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <span class="shadowHyphen"><xsl:apply-templates/></span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:apply-templates/><xsl:value-of xml:space="preserve"> </xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:w">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:pc">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: g template-->
    <!--     =         -->
    <!--mjc: format text in the <g> tag with @ref   -->
    <!--     for punctuation.                       -->
    <!--     - #puncelev = #61793                    -->
    <!--*************************-->
    <xsl:template match="tei:g">
        <xsl:choose>
            <xsl:when test="@ref='#puncelev'">
                <!--&#61793;-->
                <span class="puncelev">&#x61B; </span>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: del template-->
    <!--     ===         -->
    <!--mjc: format text in the <del> tag-->
    <!--*************************-->
    <xsl:template match="tei:del">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:if test="$view = 'diplomatic' or $view = 'alltags'">
            <xsl:choose>
                <xsl:when test="substring(text()[1], 1, 1) = '.'">{<span class="del-illegible">
                        <xsl:apply-templates/>
                    </span>}</xsl:when>
                
                <xsl:otherwise>
                    <xsl:choose>
                        <!--if the <del> is outside of a word (<l>/<seg>/<del>) then we want a space after it-->
                        <xsl:when test="parent::tei:seg/parent::tei:l">
                            {<span class="del-legible">
                                <xsl:apply-templates/>
                            </span>}
                        </xsl:when>
                        
                        <!--otherwise, we don't-->
                        <xsl:otherwise>{<span class="del-legible">
                            <xsl:apply-templates/>
                        </span>}</xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: expan template-->
    <!--     =====         -->
    <!--mjc: italicize text in the <expan> tag-->
    <!--     except in critical view.         -->
    <!--*************************-->
    <xsl:template match="tei:expan">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <xsl:apply-templates/>
            </xsl:when>
            
            <xsl:otherwise>
                <i><xsl:apply-templates/></i>
            </xsl:otherwise>
        </xsl:choose>
        
        <!--some <expan> tags are inside text() nodes and so need to preserve the following space-->
        <xsl:if test="substring(./following-sibling::text()[1], 1, 1) = ' '">
            <xsl:value-of xml:space="preserve"> </xsl:value-of>
        </xsl:if>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: hi template-->
    <!--     ==         -->
    <!--mjc: apply actions of <hi> tags except to critical view:    -->
    <!--     'it' - italics                                         -->
    <!--     'sup"- superposition                                   -->
    <!--     'ul' - underline                                       -->
    <!--     'o5' - character is 5 lines high                       -->
    <!--     'tr' - red highlight                                   -->
    <!--     'BinR'-red outline around text                         -->
    <!--*************************-->
    <xsl:template match="tei:hi">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <xsl:apply-templates/>
            </xsl:when>
            
            <xsl:otherwise>
                <span class="{@rend}"><xsl:apply-templates/></span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--*************************-->
    <!--mjc: //note/hi template-->
    <!--     =========         -->
    <!--mjc: apply actions of <hi> tags found withing <note>        -->
    <!--     tags, except to critical view:                         -->
    <!--     'it' - italics                                         -->
    <!--     'sup"- superposition                                   -->
    <!--     'ul' - underline                                       -->
    <!--     'o5' - character is 5 lines high                       -->
    <!--     'tr' - red highlight                                   -->
    <!--     'BinR'-red outline around text                         -->
    <!--*************************-->
    <xsl:template match="//tei:note/tei:hi" >
        <xsl:param name="view" tunnel="yes"/>
        
        <!--mjc:                                                        -->
        <!--====                                                        -->
        <!--Performant's tooltip utility uses the @title attribute of   -->
        <!--the <a> to generate a nicely formated roll-over box of info.-->
        <!--However, it is not able to handle HTML formatted text within-->
        <!--the @title, and I am having trouble getting the XSLT to     -->
        <!--generate this code as well. As a temporary fix, I'm going to-->
        <!--change the XSLT to surround italicized text inside <note>s  -->
        <!--with single quotes instead.                                 -->
        <!--For future release Performant will look at fixing this with -->
        <!--their tooltip or another tool. Save this code for then.     -->
        <!--============================================================-->
        <!--<xsl:variable name="openHi">&lt;span class=&#x2018;<xsl:value-of select="@rend"/>&#x2018;&gt;</xsl:variable>
        <xsl:variable name="closeHi">&lt;/span&gt;</xsl:variable>-->

        <!--<xsl:value-of disable-output-escaping="yes" select="$openHi"/><xsl:apply-templates/><xsl:value-of disable-output-escaping="yes" select="$closeHi"/>-->
        <xsl:text> '</xsl:text><xsl:apply-templates/>
        <xsl:choose>
            <xsl:when test="starts-with(following-sibling::text()[1], ' ')">
                <xsl:text>' </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>'</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: damage template-->
    <!--     ======         -->
    <!--mjc: show elipses in <damage> with aqua text in alltags view.   -->
    <!--     otherwise in black.                                        -->
    <!--*************************-->
    <xsl:template match="tei:damage">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when test="$view = 'alltags'">
                <span class="damage"><xsl:apply-templates/></span>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: choice template-->
    <!--     ======         -->
    <!--mjc: display the options in a <choice> in different ways        -->
    <!--     depending on the view. There are several types of <choice>s-->
    <!--        - <orig> / <reg>                                        -->
    <!--        - <sic> / <corr>                                        -->
    <!--*************************-->
    <xsl:template match="tei:choice">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <xsl:choose>
                    <xsl:when test="./descendant::tei:orig">
                        <span><xsl:apply-templates select="./descendant::tei:reg"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:sic">
                        <span><xsl:apply-templates select="./descendant::tei:corr"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:expan">
                        <span name="{./tei:abbr/text()}"><xsl:apply-templates select="./tei:expan"/></span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="$view = 'scribal'">
                <xsl:choose>
                    <xsl:when test="./descendant::tei:orig">
                        <span class="orig"><xsl:apply-templates select="./descendant::tei:orig"/><xsl:text xml:space="preserve"> </xsl:text></span> 
                    </xsl:when>
                    <xsl:when test="./descendant::tei:sic">
                        <span class="sic"><xsl:apply-templates select="./descendant::tei:sic"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:expan">
                        <span class="expan" name="{./tei:abbr/text()}"><i><xsl:apply-templates select="./tei:expan"/></i></span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="$view = 'diplomatic'">
                <xsl:choose>
                    <xsl:when test="./descendant::tei:orig">
                        <span><xsl:apply-templates select="./descendant::tei:orig"/><xsl:text xml:space="preserve"> </xsl:text></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:sic">
                        <span><xsl:apply-templates select="./descendant::tei:sic"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:expan">
                        <span class="expan" name="{./tei:abbr/text()}"><i><xsl:apply-templates select="./tei:expan"/></i></span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            
            <xsl:when test="$view = 'alltags'">
                <xsl:choose>
                    <xsl:when test="./descendant::tei:orig">
                        <span class="orig"><xsl:apply-templates select="./descendant::tei:orig"/> / </span><span class="reg"><xsl:apply-templates select="./descendant::tei:reg"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:sic">
                        <span class="sic"><xsl:apply-templates select="./descendant::tei:sic"/> / </span><span class="corr"><xsl:apply-templates select="./descendant::tei:corr"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:expan">
                        <span class="expan" name="{./tei:abbr/text()}"><i><xsl:apply-templates select="./tei:expan"/></i></span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            
        </xsl:choose>
    </xsl:template>
    
    
    
    
    <!-- Following is old code for the TEI:choice template.  -->
    <!--
    <xsl:template match="tei:choice">
        <xsl:param name="view" tunnel="yes"/>

        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <xsl:choose>
                    <xsl:when test="./descendant::tei:orig">
                        <span><xsl:apply-templates select="./descendant::tei:reg"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:sic">
                        <span><xsl:value-of select="./descendant::tei:corr"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:expan">
                        <span name="{./tei:abbr/text()}"><xsl:value-of select="./tei:expan/tei:seg"/></span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$view = 'scribal'">
                <xsl:choose>
                    <xsl:when test="./descendant::tei:orig">
                        <span class="orig"><xsl:apply-templates select="./descendant::tei:orig"/><xsl:value-of xml:space="preserve"> </xsl:value-of></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:sic">
                        <span class="sic"><xsl:value-of select="./descendant::tei:sic"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:expan">
                        <span class="expan" name="{./tei:abbr/text()}"><i><xsl:value-of select="./tei:expan/tei:seg"/></i></span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$view = 'diplomatic'">
                <xsl:choose>
                    <xsl:when test="./descendant::tei:orig">
                        <span><xsl:apply-templates select="./descendant::tei:orig"/><xsl:value-of xml:space="preserve"> </xsl:value-of></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:sic">
                        <span><xsl:value-of select="./descendant::tei:sic"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:expan">
                        <span class="expan" name="{./tei:abbr/text()}"><i><xsl:value-of select="./tei:expan/tei:seg"/></i></span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$view = 'alltags'">
                <xsl:choose>
                    <xsl:when test="./descendant::tei:orig">
                        <span class="orig"><xsl:value-of select="./descendant::tei:orig"/> / </span><span class="reg"><xsl:apply-templates select="./descendant::tei:reg"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:sic">
                        <span class="sic"><xsl:value-of select="./descendant::tei:sic"/> / </span><span class="corr"><xsl:value-of select="./descendant::tei:corr"/></span>
                    </xsl:when>
                    <xsl:when test="./descendant::tei:expan">
                        <span class="expan" name="{./tei:abbr/text()}"><i><xsl:value-of select="./tei:expan/tei:seg"/></i></span>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>

        </xsl:choose>
    </xsl:template>
    -->



    <!--*************************-->
    <!--mjc: add template-->
    <!--     ===         -->
    <!--mjc: format text in the <add> tag           -->
    <!--     output in gray font for AllTags view   -->
    <!--*************************-->
    <xsl:template match="tei:add">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when test="$view = 'alltags' or $view = 'scribal'">
                <a id="add-{@place}" class="standard-tooltip" title="{concat('Place: ', @place, ', Hand: ', @hand)}"><font color="gray"><xsl:apply-templates/></font></a>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: trailer template-->
    <!--     =======   ========         -->
    <!--mjc: format text in the <trailer> tags   -->
    <!--     display in italics (except Crit) and use @place to -->
    <!--     populate @class field.                             -->
    <!--*************************-->
    <xsl:template match="tei:trailer">
        <xsl:param name="view" tunnel="yes"/>
        
        <div class="{@place}">
            <xsl:choose>
                <xsl:when test="$view='critical'">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <i>
                        <xsl:call-template name="generateMarginalia">
                            <xsl:with-param name="marginals" select="key('marginal',generate-id())"/>
                        </xsl:call-template>
                        <xsl:apply-templates/>
                    </i>
                </xsl:otherwise>
            </xsl:choose>
        </div>
        
<!--        <xsl:choose>
            <xsl:when test="$view = 'critical'">
                <div class="{@place}"><xsl:apply-templates/></div>
                <!-\-mjc: tell parser not to turn  into <br></br>-\->
                <xsl:value-of disable-output-escaping="yes">&lt;br /&gt;</xsl:value-of>
            </xsl:when>
            
            <xsl:otherwise>
                <div class="{@place}"><i><xsl:apply-templates/></i></div>
                <!-\-mjc: tell parser not to turn  into <br></br>-\->
                <xsl:value-of disable-output-escaping="yes">&lt;br /&gt;</xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>-->
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: marginalia template-->
    <!--     ==========         -->
    <!--mjc: format text in the <marginalia> tag    -->
    <!--     except for Critical view.              -->
    <!--     use @place to populate @class field.   -->
    <!--*************************-->
    
    <xsl:key name="marginal" match="//tei:marginalia[starts-with(@place, 'margin')] | //tei:fw[starts-with(@place, 'margin')]"
        use="generate-id(following-sibling::*[name() = 'l' or name() = 'head' or name() = 'trailer'][1])"/>
    
    <!--<xsl:template name="generateMarginalia">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:param name="margin"/>
        
        <xsl:choose>
            <xsl:when test="$view = 'critical'"/>
            
            <xsl:otherwise>
                <xsl:for-each select="$margin">
                    <div class="margin-{@place}"><a id="margin-{@place}" class="standard-tooltip" title="{concat('Place: ', @place, ', Hand: ', @hand)}"><xsl:apply-templates/></a></div>
                </xsl:for-each>
                
                <!-\-mjc: in some cases there can be multiple <marginalia> tags in a row  -\->
                <!-\-     handle that special condition here                              -\->
                <xsl:if test="name($margin/following-sibling::*[1])='marginalia'">
                    <xsl:variable name="pos" select="substring($margin/following-sibling::*[1]/attribute::place, 1, 3)"/>
                    
                    <!-\-if the @place value of the next <marginalia> is top or bottom, then insert a <br/>-\-> 
                    <xsl:if test="$pos='top' or $pos='bot'">
                        <!-\-mjc: tell parser not to turn  into <br></br>-\->
                        <xsl:value-of disable-output-escaping="yes">&lt;br /&gt;</xsl:value-of>
                    </xsl:if>
                    
                    <xsl:call-template name="generateMarginalia">
                        <xsl:with-param name="margin" select="$margin/following-sibling::tei:marginalia[1]"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    
    <xsl:template name="generateMarginalia">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:param name="marginals"/>
        <xsl:param name="in_margin" select="true()"/>
        
        <xsl:choose>
            <xsl:when test="$view = 'critical'"/>
            
            <xsl:otherwise>
                <xsl:for-each select="$marginals">
                    <div class="{if ($in_margin) then 'margin-' else ''}{@place}"><a class="standard-tooltip" title="{concat('Place: ', @place, ', Hand: ', @hand)}"><xsl:apply-templates/></a></div>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--pab: exclude marginalia that's already covered or that we don't otherwise want to display; process the rest-->
    <xsl:template match="tei:marginalia[starts-with(@place,'margin')] | tei:fw[starts-with(@place,'margin')]"/>
    <xsl:template match="tei:fw[@type='runningHead']"/>
    <xsl:template match="tei:marginalia | tei:fw">
        <xsl:call-template name="generateMarginalia">
            <xsl:with-param name="marginals" select="."/>
            <xsl:with-param name="in_margin" select="false()"/>
        </xsl:call-template>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: note template-->
    <!--     ====         -->
    <!--mjc: format <notes>: create red, super-script   -->
    <!--     capital T, with link to something. for now -->
    <!--     put the text of the note in a @title       -->
    <!--*************************-->
    <xsl:template match="tei:note">
        <xsl:param name="view" tunnel="yes"/>
       
        <xsl:variable name="noteBody">
	       <xsl:apply-templates/>
        </xsl:variable> 

        <xsl:choose>
            <xsl:when test="$view = 'diplomatic'"/>
                
            <xsl:otherwise>
                <a id="supNote" class="standard-tooltip" title="{$noteBody}"><span class="supNote">N</span></a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--*************************-->
    <!--mjc: supplied template-->
    <!--     ========         -->
    <!--mjc: format <supplied>: put text in [],   -->
    <!--     except for Diplomatic view.          -->         
    <!--pab added logic to output question marks  -->
    <!--     in Diplomatic view. Also eliminated  -->
    <!--     extra whitespace around brackets.    -->
    <!--*************************-->
    <xsl:template match="tei:supplied">
        <xsl:param name="view" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when test="$view = 'diplomatic'">
                <span class="supplied">
                    <xsl:for-each select="1 to string-length(string-join(descendant::text()[not(ancestor::tei:note)],''))">
                        <xsl:text>?</xsl:text>
                    </xsl:for-each>
                </span>
            </xsl:when>
            
            <xsl:otherwise>[<span class="supplied"><xsl:apply-templates/></span>]</xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <!--*************************-->
    <!--pab: space template-->
    <!--     ========      -->
    <!--pab: replace horizontal <space> with      -->
    <!--     number of nbsp characters listed in  -->
    <!--     extent.                              -->
    <!--*************************-->
    <xsl:template match="tei:space[@dim='horizontal']">
        <xsl:variable name="len" as="xs:integer">
            <xsl:choose>
                <xsl:when test="@quantity castable as xs:integer and @unit='chars'">
                    <xsl:value-of select="@quantity"/>
                </xsl:when>
                <xsl:when test="@extent castable as xs:integer">
                    <xsl:value-of select="@extent"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="1 to $len">
            <xsl:text>&#8194;</xsl:text>
        </xsl:for-each>
    
    </xsl:template>
    
    <!--*************************-->
    <!--pab: gap template -->
    <!--     ========      -->
    <!--pab: replace gap with appropriate chars   -->
    <!--     based on listed length, or ellipsis  -->
    <!--     is gap takes up entire line.         -->
    <!--*************************-->
    <xsl:template match="tei:gap">
        <xsl:variable name="length" as="xs:integer">
            <xsl:choose>
                <xsl:when test="@quantity">
                    <xsl:value-of select="@quantity"/>
                </xsl:when>
                <xsl:when test="@atLeast and @atMost">
                    <xsl:value-of select="round(sum(@atLeast,@atMost) div 2)"/>
                </xsl:when>
                <xsl:when test="@atLeast">
                    <xsl:value-of select="@atLeast"/>
                </xsl:when>
                <xsl:when test="@atMost">
                    <xsl:value-of select="@atMost"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="range">
            <xsl:choose>
                <xsl:when test="@unit='chars' and @atLeast='6' and @atMost='12'">lessThanHalf</xsl:when>
                <xsl:when test="@unit='lines' and @atLeast='0.5' and @atMost='1'">moreThanHalf</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <span class="gap">
            <xsl:choose>
                <xsl:when test="string-length($range) > 0"><xsl:text>…</xsl:text></xsl:when>
                <xsl:when test="@extent = 'rest of line'"><xsl:text>…</xsl:text></xsl:when>
                <xsl:when test="@unit='lines'">
                    <xsl:text>[</xsl:text>
                    <xsl:if test="@quantity > 1"><xsl:value-of select="@quantity"/><xsl:text> </xsl:text></xsl:if>
                    <xsl:text>line</xsl:text>
                    <xsl:if test="@quantity > 1"><xsl:text>s</xsl:text></xsl:if>
                    <xsl:text> illegible]</xsl:text>
                </xsl:when>
                <xsl:when test="@unit='chars'">
                    <xsl:for-each select="1 to $length">
                        <xsl:text>?</xsl:text>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise><xsl:text>…</xsl:text></xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    
    <!--*************************-->
    <!--pab: addSpan template and key-->
    <!--     ========      -->
    <!--pab: treat addSpanned nodes inside l,     -->
    <!--     head, trailer, marginalia, fw as     -->
    <!--     though they are in <add> elements.   -->
    <!--     Adapted from a technique I created   -->
    <!--     for the PPEA.                        -->
    <!--*************************-->
    <xsl:key name="addSpannedNodeIds" match="tei:addSpan">
        <xsl:variable name="n" select="."/>
        <xsl:variable name="target" select="id(substring-after(@spanTo,'#'))"/>
        <xsl:variable name="all_between"
            select="$n/following::node() intersect $target/preceding::node()"/>
        <!-- The sequence contains all top-level children of the virtual element created by the span. $all_between contains
            every node between the opening and closing of the span. However, when identifying the contents of the span to
            wrap them, we want to identify only the top-level elements; a node whose parent has been identified as belonging
            to the span should not itself also be identified as belonging to the span, for locating the parent in the span
            covers it. The sequence selector returns every node in the $all_between nodeset except those nodes whose parent
            element is found in the $all_between nodeset. Or, to be more precise, it returns IDs for all nodes meeting
            those conditions. -->
        <xsl:sequence
            select="
            (for $o in $all_between[not(descendant-or-self::tei:l or descendant-or-self::tei:head or descendant-or-self::tei:trailer or descendant-or-self::tei:marginalia or descendant-or-self::tei:fw or self::tei:milestone or self::tei:pb or self::tei:cb)]
            return
            $o[not($all_between[. is $o/parent::*])])/generate-id()"/>
    </xsl:key>
    
    <xsl:template match="node()[key('addSpannedNodeIds', generate-id())]" priority="2000">
        <xsl:param name="view" tunnel="yes"/>
        <xsl:variable name="addSpan" select="key('addSpannedNodeIds', generate-id())"/>
        
        <!-- Create a version of the node that's wrapped in an <add> element, allowing us to process it like any other <add>. -->
        <xsl:variable name="node_in_add">
            <tei:add place="{$addSpan/@place}" hand="{$addSpan/@hand}">
                <xsl:copy-of select="."/>
            </tei:add>
        </xsl:variable>
        
        <xsl:apply-templates select="$node_in_add"/>
    </xsl:template>


    <xsl:template match="text()">
        <xsl:value-of select="if (string-length(normalize-space()) ne 0) then normalize-space() else ." />
    </xsl:template>
    
    
</xsl:stylesheet>
