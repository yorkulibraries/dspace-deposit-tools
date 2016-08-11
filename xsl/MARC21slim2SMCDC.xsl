<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="marc">
	<xsl:import href="MARC21slimUtils.xsl"/>
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

	<xsl:template match="/">
			<xsl:apply-templates/>
	</xsl:template>
	
  <xsl:template match="marc:record">
    <xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag=008]"/>
		
		<entry xmlns="http://www.w3.org/2005/Atom" xmlns:dcterms="http://purl.org/dc/terms/">
			<xsl:for-each select="marc:datafield[@tag=245]">				
				<xsl:variable name="title">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">a</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="substring($title, string-length($title), 1)='/' or substring($title, string-length($title), 1)=':'">
						<dcterms:title>
							<xsl:value-of select="substring($title, 0, string-length($title)-1)"/>
						</dcterms:title>
					</xsl:when>
					<xsl:otherwise>
						<dcterms:title>
							<xsl:value-of select="$title"/>
						</dcterms:title>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
				
			<xsl:for-each select="marc:datafield[@tag=246]">
				<dcterms:alternative>  <!---according to DC namespace at http://dublincore.org/documents/2012/06/14/dcmi-terms/?v=terms#terms-alternative -->
					<xsl:value-of select="substring-before(marc:subfield[@code='a'], '.')"/>	
				</dcterms:alternative>
			</xsl:for-each>
			
			<xsl:for-each select="marc:datafield[@tag=700]|marc:datafield[@tag=710]|marc:datafield[@tag=711]|marc:datafield[@tag=720]">
				<xsl:variable name="creator">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">a</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="role">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">e</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="fuller_form">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">q</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>	
				<xsl:choose>
					<xsl:when test="substring($creator, string-length($creator), 1)=',' and $role != '' and $fuller_form = ''">						
						<xsl:variable name="creator1">
							<xsl:value-of select="substring($creator, 0, string-length($creator))"/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="substring($role, string-length($role), 1)='.'">
								<dcterms:creator>							
									<xsl:value-of select="concat($creator1, ' [', substring-before($role, '.'), ']')"/>
								</dcterms:creator>
							</xsl:when>
							<xsl:otherwise>						
								<dcterms:creator>							
									<xsl:value-of select="concat($creator1, ' [', $role, ']')"/>
								</dcterms:creator>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="substring($creator, string-length($creator), 1)=',' and $role = '' and $fuller_form = ''">						
						<xsl:variable name="creator1">
							<xsl:value-of select="substring($creator, 0, string-length($creator))"/>
						</xsl:variable>
						<dcterms:creator>							
							<xsl:value-of select="$creator1"/>
						</dcterms:creator>
					</xsl:when>
					<xsl:when test="$fuller_form != ''">
						<xsl:variable name="creator1">
							<xsl:value-of select="substring($creator, 0, string-length($creator)+1)"/>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="substring($role, string-length($role), 1)='.'">
								<dcterms:creator>							
									<xsl:value-of select="concat($creator1, ' ', substring-before($fuller_form, ','), ' [', substring-before($role, '.'), ']')"/>
								</dcterms:creator>
							</xsl:when>
							<xsl:otherwise>						
								<dcterms:creator>							
									<xsl:value-of select="concat($creator1, ' ', substring-before($fuller_form, ','), ' [', $role, ']')"/>
								</dcterms:creator>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="$creator='John Arpin Collection - York University.'">
					</xsl:when>
					<xsl:otherwise>						
						<dcterms:creator>
							<xsl:value-of select="$creator"/>
						</dcterms:creator>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:for-each>

			<dcterms:type>				
				<xsl:text>Sheet Music</xsl:text>
			</dcterms:type>
			
			<dcterms:rights>				
				<xsl:text>For further copyright information contact : ascproj@yorku.ca</xsl:text>
			</dcterms:rights>
			
			<dcterms:rights>
				<xsl:text>http://bit.ly/SheetMusicFAQ</xsl:text>
			</dcterms:rights>
			
			<dcterms:isPartOfSeries>				
				<xsl:variable name="identifier">
					<xsl:value-of select="marc:datafield[@tag=090]/marc:subfield[@code='a']"/>
				</xsl:variable>				
				<xsl:choose>
					<xsl:when test="substring($identifier, 1, 3)='JAC'">
						<xsl:text>John Arpin Sheet Music Collection</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Sheet Music Collection</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</dcterms:isPartOfSeries>			

			<xsl:for-each select="marc:datafield[@tag=260]">
				<dcterms:publisher>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abc</xsl:with-param>
					</xsl:call-template>
				</dcterms:publisher>
			</xsl:for-each>

			<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='c']">
				<dcterms:issued>
					<xsl:variable name="date">
						<xsl:value-of select="."/>
					</xsl:variable>					
					<xsl:choose>						
						<xsl:when test="$date='Year' or $date='year'">
							<xsl:value-of select="'[n.d.]'"/>
						</xsl:when>
						<xsl:when test="substring($date, string-length($date))=']' and $date!='[n.d.]'">
							<xsl:value-of select="substring-before(substring-after($date, '['), ']')"/>
						</xsl:when>
						<xsl:when test="substring($date, string-length($date))='.'">
							<xsl:value-of select="substring-before($date, '.')"/>
						</xsl:when>
						<xsl:otherwise>							
							<xsl:value-of select="$date"/>							
						</xsl:otherwise>
					</xsl:choose>	
				</dcterms:issued>				
			</xsl:for-each>
			
			<xsl:for-each select="marc:datafield[@tag=300]">
				<dcterms:format>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abc</xsl:with-param>
					</xsl:call-template>
				</dcterms:format>
			</xsl:for-each>

			<dcterms:language>
				<xsl:variable name="language">
					<xsl:value-of select="substring($controlField008,36,3)"/>
				</xsl:variable>
				<xsl:if test="$language='eng'">
					<xsl:value-of select="'en'"/>
				</xsl:if>
			</dcterms:language>			

			<xsl:for-each select="marc:datafield[@tag=500]">
				<dcterms:description>
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</dcterms:description>
			</xsl:for-each>			

			<xsl:for-each select="marc:datafield[@tag=090]">
				<dcterms:identifier>
					<xsl:value-of select="marc:subfield[@code='a']"/>
				</dcterms:identifier>
			</xsl:for-each>
    </entry>
  </xsl:template>
	
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c)1998-2002 eXcelon Corp.
<metaInformation>
<scenarios ><scenario default="no" name="MODS Website Samples" userelativepaths="yes" externalpreview="no" url="..\xml\MARC21slim\modswebsitesamples.xml" htmlbaseurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/><scenario default="no" name="Ray Charles" userelativepaths="yes" externalpreview="no" url="..\xml\MARC21slim\raycharles.xml" htmlbaseurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/><scenario default="yes" name="s6" userelativepaths="yes" externalpreview="no" url="..\ifla\sally6.xml" htmlbaseurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/><scenario default="no" name="s7" userelativepaths="yes" externalpreview="no" url="..\ifla\sally7.xml" htmlbaseurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/><scenario default="no" name="s12" userelativepaths="yes" externalpreview="no" url="..\ifla\sally12.xml" htmlbaseurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/></scenarios><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->
