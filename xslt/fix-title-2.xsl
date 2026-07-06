<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs tei" version="2.0">
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <!-- ================================================= -->
  <!-- Identity template                                 -->
  <!-- ================================================= -->

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================= -->
  <!-- Replace <title>nil</title>                         -->
  <!-- ================================================= -->

  <xsl:template match="tei:title[normalize-space(.) = 'nil']">

    <!-- Danish -->
    <xsl:for-each select="//tei:profileDesc/tei:creation/tei:date[@xml:lang = 'da']">
      <title xml:lang="da">
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:if test="//tei:creation/tei:placeName">
          <xsl:text> </xsl:text>
          <xsl:value-of select="normalize-space(//tei:creation/tei:placeName[1])"/>
        </xsl:if>
      </title>
    </xsl:for-each>

    <!-- English -->
    <xsl:for-each select="//tei:profileDesc/tei:creation/tei:date[@xml:lang = 'en']">
      <title xml:lang="en">
        <xsl:value-of select="normalize-space(.)"/>
      </title>
    </xsl:for-each>

  </xsl:template>

  <xsl:template match="//tei:editor">
    <xsl:choose>
      <xsl:when test="tei:name[@xml:id = 'pz']">
        <editor role="pub_editor">Peter Zeeberg</editor>
      </xsl:when>
      <xsl:when test="tei:name[@xml:id = 'sis']">
        <editor role="pub_editor">Signe Strecker</editor>
      </xsl:when>
    </xsl:choose>
    <editor role="data_engineer">Thomas Hansen</editor>
  </xsl:template>


  <!-- ================================================= -->
  <!-- Replace <witness>                                 -->
  <!-- ================================================= -->

  <xsl:template match="tei:witness">
    <xsl:choose>
      <xsl:when test="@xml:id = 'TBOO'">
        <witness xml:id="TBOO_da">
          <xsl:apply-templates/>
        </witness>
        <witness xml:id="TBOO_en">
          <xsl:apply-templates/>
        </witness>
      </xsl:when>
      <xsl:when test="tei:bibl">
        <witness>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="@xml:id"/><xsl:text>_da</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </witness>
        <witness>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="@xml:id"/><xsl:text>_en</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates/>
        </witness>
      </xsl:when>
      <xsl:otherwise>

        <xsl:variable name="id" select="@xml:id"/>

        <xsl:for-each select="tei:msDesc">

          <xsl:variable name="lang" select="@xml:lang"/>

          <witness xml:id="{concat($id, '_', $lang)}">

            <xsl:call-template name="join-msIdentifier"/>

          </witness>

        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>


  </xsl:template>

  <!-- ================================================= -->
  <!-- Build comma-separated string                      -->
  <!-- ================================================= -->

  <xsl:template name="join-msIdentifier">

    <xsl:for-each
      select="tei:msIdentifier/*[normalize-space(.) != '' and normalize-space(.) != 'empty']">

      <xsl:value-of select="normalize-space(.)"/>

      <xsl:if test="position() != last()">, </xsl:if>

    </xsl:for-each>

  </xsl:template>


  <!-- ================================================= -->
  <!-- Add @when to <creation>                           -->
  <!-- ================================================= -->

  <xsl:template match="tei:creation">
    <!--<xsl:if test="//correspAction[@type='sent']/tei:placeName">
      <xsl:variable name="place" select="//correspAction[@type='sent']/tei:placeName"/>-->
    <xsl:copy>
      <xsl:apply-templates/>
      <xsl:if test="//tei:correspAction[@type = 'sent']/tei:placeName">
        <placeName xml:lang="da">
          <xsl:value-of
            select="normalize-space(//tei:correspAction[@type = 'sent']/tei:placeName[1])"/>
        </placeName>
        <placeName xml:lang="en">
          <xsl:value-of
            select="normalize-space(//tei:correspAction[@type = 'sent']/tei:placeName[1])"/>
        </placeName>
      </xsl:if>
    </xsl:copy>
    <!--</xsl:if>-->
  </xsl:template>

  <xsl:template match="tei:creation/tei:date">

    <!-- get the sent-date value -->
    <xsl:variable name="when" select="//tei:correspAction[@type = 'sent']/tei:date/@when"/>

    <xsl:copy>

      <!-- copy existing attributes -->
      <xsl:apply-templates select="@*"/>

      <!-- add @when -->
      <xsl:if test="not(@when) and string($when)">
        <xsl:attribute name="when">
          <xsl:value-of select="$when"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="normalize-space(.)"/>

    </xsl:copy>

  </xsl:template>


  <!-- ================================================= -->
  <!-- Make abstract                                     -->
  <!-- ================================================= -->
  <xsl:template match="tei:abstract">
    <abstract xml:lang="da">
      <p>
        <xsl:text>Brev fra </xsl:text>
        <xsl:choose>
          <xsl:when test="//tei:correspAction[@type = 'sent']/tei:persName[@xml:lang = 'da']">
            <xsl:value-of
              select="//tei:correspAction[@type = 'sent']/tei:persName[@xml:lang = 'da']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="//tei:correspAction[@type = 'sent']/tei:persName[1]"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> til </xsl:text>
        <xsl:choose>
          <xsl:when test="//tei:correspAction[@type = 'received']/tei:persName[@xml:lang = 'da']">
            <xsl:value-of
              select="//tei:correspAction[@type = 'received']/tei:persName[@xml:lang = 'da']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="//tei:correspAction[@type = 'received']/tei:persName[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </abstract>
    <abstract xml:lang="en">
      <p>
        <xsl:text>Letter from </xsl:text>
        <xsl:choose>
          <xsl:when test="//tei:correspAction[@type = 'sent']/tei:persName[@xml:lang = 'en']">
            <xsl:value-of
              select="//tei:correspAction[@type = 'sent']/tei:persName[@xml:lang = 'en']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="//tei:correspAction[@type = 'sent']/tei:persName[1]"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> to </xsl:text>
        <xsl:choose>
          <xsl:when test="//tei:correspAction[@type = 'received']/tei:persName[@xml:lang = 'en']">
            <xsl:value-of
              select="//tei:correspAction[@type = 'received']/tei:persName[@xml:lang = 'en']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="//tei:correspAction[@type = 'received']/tei:persName[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </abstract>
  </xsl:template>

  <!-- ================================================= -->
  <!-- Remove <note> inside <rdg>, keep its content       -->
  <!-- ================================================= -->

  <xsl:template match="tei:rdg/tei:note">
    <xsl:apply-templates/>
  </xsl:template>


  <!--tag text as 'brev'-->
  <xsl:template match="tei:textClass/tei:keywords">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(tei:term = 'brev')">
        <term xmlns="http://www.tei-c.org/ns/1.0">brev</term>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  <!-- <xsl:template match="//tei:textClass/tei:keywords/tei:term"> -->
  <!--   <term>brev</term> -->
  <!-- </xsl:template> -->

  <!-- normalize language value -->
  <xsl:template match="//tei:langUsage">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="tei:language[@ident = 'da']">
          <language ident="da">dansk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'dum']">
          <language ident="dum">nederlandsk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'en']">
          <language ident="en">engelsk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'gda']">
          <language ident="gda">dansk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'xda']">
          <language ident="xda">dansk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'gr']">
          <language ident="gr">græsk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'gmh']">
          <language ident="gmh">tysk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'gml']">
          <language ident="gml">tysk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'la']">
          <language ident="la">latin</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'lat']">
          <language ident="la">latin</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'nl']">
          <language ident="nl">nederlandsk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'xno']">
          <language ident="fr">fransk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'gsv']">
          <language ident="se">svensk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'se']">
          <language ident="se">svensk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'sv']">
          <language ident="se">svensk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'Ældre nydansk']">
          <language ident="xda">dansk</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'nil']">
          <language ident="nil">latin</language>
        </xsl:when>
        <xsl:when test="tei:language[@ident = 'empty']">
          <language ident="empty">latin</language>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
