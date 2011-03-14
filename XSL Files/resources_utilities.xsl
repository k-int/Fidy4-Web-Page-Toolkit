<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:ecdrec="http://dcsf.gov.uk/XMLSchema/Childcare"
								xmlns:fsdrec="http://dcsf.gov.uk/XMLSchema/ServiceDirectory"
								xmlns:srw="http://www.loc.gov/zing/srw/"
                xmlns:facet="http://k-int.com/facet"
								xmlns:jzkit="http://www.k-int.com/jzkit/"
								xmlns:apd="http://www.govtalk.gov.uk/people/AddressAndPersonalDetails"
								xmlns:con="http://www.govtalk.gov.uk/people/ContactTypes"
								xmlns:bs7666="http://www.govtalk.gov.uk/people/bs7666">

  <xsl:import href="envirovars.xsl" />
  <xsl:output method="html" encoding="utf-8" indent="yes" />

  <!-- template utility 'function' for decoding URL entities -->
  <xsl:template name="decode">
    <xsl:param name="encoded"/>
    <xsl:variable name="hex" select="'0123456789ABCDEF'"/>
    <xsl:variable name="ascii"> !"#$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~</xsl:variable>
    <xsl:variable name="latin1">&#160;&#161;&#162;&#163;&#164;&#165;&#166;&#167;&#168;&#169;&#170;&#171;&#172;&#173;&#174;&#175;&#176;&#177;&#178;&#179;&#180;&#181;&#182;&#183;&#184;&#185;&#186;&#187;&#188;&#189;&#190;&#191;&#192;&#193;&#194;&#195;&#196;&#197;&#198;&#199;&#200;&#201;&#202;&#203;&#204;&#205;&#206;&#207;&#208;&#209;&#210;&#211;&#212;&#213;&#214;&#215;&#216;&#217;&#218;&#219;&#220;&#221;&#222;&#223;&#224;&#225;&#226;&#227;&#228;&#229;&#230;&#231;&#232;&#233;&#234;&#235;&#236;&#237;&#238;&#239;&#240;&#241;&#242;&#243;&#244;&#245;&#246;&#247;&#248;&#249;&#250;&#251;&#252;&#253;&#254;&#255;</xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($encoded,'%')">
        <xsl:value-of select="substring-before($encoded,'%')"/>
        <xsl:variable name="hexpair" select="translate(substring(substring-after($encoded,'%'),1,2),'abcdef','ABCDEF')"/>
        <xsl:variable name="decimal" select="(string-length(substring-before($hex,substring($hexpair,1,1))))*16 + string-length(substring-before($hex,substring($hexpair,2,1)))"/>
        <xsl:choose>
          <xsl:when test="$decimal &lt; 127 and $decimal &gt; 31">
            <xsl:value-of select="substring($ascii,$decimal - 31,1)"/>
          </xsl:when>
          <xsl:when test="$decimal &gt; 159">
            <xsl:value-of select="substring($latin1,$decimal - 159,1)"/>
          </xsl:when>
          <xsl:otherwise>?</xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="decode">
          <xsl:with-param name="encoded" select="substring(substring-after($encoded,'%'),3)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$encoded"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- template utility 'function' for encoding HTML entities -->
  <xsl:template name="encode">
    <xsl:param name="uncoded"/>
    <xsl:variable name="raw">&lt;&gt;£&apos;&quot;</xsl:variable>
    <xsl:variable name="coded">&#60;&#62;&#163;&#39;'</xsl:variable>
    <xsl:value-of select="translate($uncoded, $raw, $coded)"/>
  </xsl:template>

  <!-- template 'function' for capitalising stuff -->
  <xsl:template name="capitalise">
    <xsl:param name="source" />
    <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:value-of select="concat(translate(substring($source,1,1),$lcletters,$ucletters), substring($source,2))"/>
  </xsl:template>

  <!-- template 'function' for formatting dates -->
  <!-- converts FROM 2001-12-31T12:00:00 to new format 31 December 2001 -->
  <!-- R04: Code required for List View tool start -->
  <xsl:template name="dateMaker">
    <xsl:param name="DateTime" />
    <xsl:variable name="year">
      <xsl:value-of select="substring($DateTime,1,4)" />
    </xsl:variable>
    <xsl:variable name="month-temp">
      <xsl:value-of select="substring-after($DateTime,'-')" />
    </xsl:variable>
    <xsl:variable name="month">
      <xsl:value-of select="substring-before($month-temp,'-')" />
    </xsl:variable>
    <xsl:variable name="day-temp">
      <xsl:value-of select="substring-after($month-temp,'-')" />
    </xsl:variable>
    <xsl:variable name="day">
      <xsl:value-of select="substring($day-temp,1,2)" />
    </xsl:variable>
    <xsl:value-of select="$day"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="$month = '1' or $month = '01'">January</xsl:when>
      <xsl:when test="$month = '2' or $month = '02'">February</xsl:when>
      <xsl:when test="$month = '3' or $month = '03'">March</xsl:when>
      <xsl:when test="$month = '4' or $month = '04'">April</xsl:when>
      <xsl:when test="$month = '5' or $month = '05'">May</xsl:when>
      <xsl:when test="$month = '6' or $month = '06'">June</xsl:when>
      <xsl:when test="$month = '7' or $month = '07'">July</xsl:when>
      <xsl:when test="$month = '8' or $month = '08'">August</xsl:when>
      <xsl:when test="$month = '9' or $month = '09'">September</xsl:when>
      <xsl:when test="$month = '10'">October</xsl:when>
      <xsl:when test="$month = '11'">November</xsl:when>
      <xsl:when test="$month = '12'">December</xsl:when>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$year"/>
  </xsl:template>
  <!-- R04: Code required for List View tool start -->

  <!-- template 'function' for formatting times -->
  <!-- converts FROM 12:30:00Z to new format 12:30 -->
  <xsl:template name="timeMaker">
    <xsl:param name="time" />
    <xsl:variable name="hour-temp">
      <xsl:value-of select="substring-before($time,':')" />
    </xsl:variable>
    <xsl:variable name="hour">
      <xsl:value-of select="normalize-space($hour-temp)" />
    </xsl:variable>
    <xsl:variable name="min-temp">
      <xsl:value-of select="substring-after($time,':')" />
    </xsl:variable>
    <xsl:variable name="min">
      <xsl:value-of select="substring($min-temp,1,2)" />
    </xsl:variable>
    <xsl:value-of select="$hour"/>
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$min"/>
  </xsl:template>

  <!-- superior (though massive!) template 'function' for formatting bs7666 address -->
  <!-- Code required for displaying address information - do not remove or modify start -->
  <xsl:template match="apd:BS7666Address">
    <!-- set up the various parts of the SAON as variables -->
    <xsl:variable name="strSecObjNum">
      <xsl:value-of select="normalize-space(bs7666:SAON/bs7666:StartRange/bs7666:Number)"/>
    </xsl:variable>
    <xsl:variable name="strSecObjSuf">
      <xsl:value-of select="normalize-space(bs7666:SAON/bs7666:StartRange/bs7666:Suffix)"/>
    </xsl:variable>
    <xsl:variable name="strSecObjRng">
      <xsl:value-of select="normalize-space(bs7666:SAON/bs7666:EndRange/bs7666:Number)"/>
    </xsl:variable>
    <xsl:variable name="strSecObjRsf">
      <xsl:value-of select="normalize-space(bs7666:SAON/bs7666:EndRange/bs7666:Suffix)"/>
    </xsl:variable>
    <xsl:variable name="SAODescription">
      <xsl:value-of select="normalize-space(bs7666:SAON/bs7666:Description)"/>
    </xsl:variable>
    <xsl:variable name="SAOPropertyNumber">
      <xsl:choose>
        <xsl:when test="string-length($strSecObjNum)>0">
          <xsl:value-of select="$strSecObjNum"/>
          <xsl:value-of select="$strSecObjSuf"/>
          <xsl:choose>
            <xsl:when test="string-length($strSecObjRng)>0"> - <xsl:value-of select="$strSecObjRng"/>
              <xsl:value-of select="$strSecObjRsf"/>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <!-- set up the various parts of the PAON as variables -->
    <xsl:variable name="strPriObjNum">
      <xsl:value-of select="normalize-space(bs7666:PAON/bs7666:StartRange/bs7666:Number)"/>
    </xsl:variable>
    <xsl:variable name="strPriObjSuf">
      <xsl:value-of select="normalize-space(bs7666:PAON/bs7666:StartRange/bs7666:Suffix)"/>
    </xsl:variable>
    <xsl:variable name="strPriObjRng">
      <xsl:value-of select="normalize-space(bs7666:PAON/bs7666:EndRange/bs7666:Number)"/>
    </xsl:variable>
    <xsl:variable name="strPriObjRsf">
      <xsl:value-of select="normalize-space(bs7666:PAON/bs7666:EndRange/bs7666:Suffix)"/>
    </xsl:variable>
    <xsl:variable name="PAODescription">
      <xsl:value-of select="normalize-space(bs7666:PAON/bs7666:Description)"/>
    </xsl:variable>
    <xsl:variable name="PAOPropertyNumber">
      <xsl:choose>
        <xsl:when test="string-length($strPriObjNum)>0">
          <xsl:value-of select="$strPriObjNum"/>
          <xsl:value-of select="$strPriObjSuf"/>
          <xsl:choose>
            <xsl:when test="string-length($strPriObjRng)>0"> - <xsl:value-of select="$strPriObjRng"/>
              <xsl:value-of select="$strPriObjRsf"/>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="Street">
      <xsl:value-of select="normalize-space(bs7666:StreetDescription)"/>
    </xsl:variable>
    <xsl:variable name="Locality">
      <xsl:value-of select="normalize-space(bs7666:Locality)"/>
    </xsl:variable>
    <xsl:variable name="Town">
      <xsl:value-of select="normalize-space(bs7666:Town)"/>
    </xsl:variable>
    <xsl:variable name="PostTown">
      <xsl:value-of select="normalize-space(bs7666:PostTown)"/>
    </xsl:variable>
    <xsl:variable name="AdministrativeArea">
      <xsl:value-of select="normalize-space(bs7666:AdministrativeArea)"/>
    </xsl:variable>
    <xsl:variable name="PostCode">
      <xsl:value-of select="normalize-space(bs7666:PostCode)"/>
    </xsl:variable>
    <!-- now create a set of booleans which identify which bits we have -->
    <xsl:variable name="bSAODescription">
      <xsl:choose>
        <xsl:when test="string-length($SAODescription)=0">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bSAOPropertyNumber">
      <xsl:choose>
        <xsl:when test="string-length($SAOPropertyNumber)=0">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bPAODescription">
      <xsl:choose>
        <xsl:when test="string-length($PAODescription)=0">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bPAOPropertyNumber">
      <xsl:choose>
        <xsl:when test="string-length($PAOPropertyNumber)=0">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bStreet">
      <xsl:choose>
        <xsl:when test="string-length($Street)=0">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bLocality">
      <xsl:choose>
        <xsl:when test="string-length($Locality)=0">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bTown">
      <xsl:choose>
        <xsl:when test="string-length($Town)=0">N</xsl:when>
        <xsl:when test="$Town=$PostTown">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bPostTown">
      <xsl:choose>
        <xsl:when test="string-length($PostTown)=0">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bAdministrativeArea">
      <xsl:choose>
        <xsl:when test="string-length($AdministrativeArea)=0">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bPostCode">
      <xsl:choose>
        <xsl:when test="string-length($PostCode)=0">N</xsl:when>
        <xsl:otherwise>Y</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="PCaddressLine">
      <xsl:choose>
        <xsl:when test="$bPostCode='Y'">
          <xsl:value-of select="$PostCode"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="AddressLine0">
      <xsl:choose>
        <xsl:when test="$bSAODescription='Y'">
          <xsl:value-of select="$SAODescription"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="LineCount0">
      <xsl:choose>
        <xsl:when test="$bSAODescription='N'">0</xsl:when>
        <xsl:otherwise>
          <xsl:number value="1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="AddressLine1">
      <!-- pSAODescription on line 1 and there is either SAOPropertyNumber or PAODescription -->
      <!-- so output them-->
      <xsl:choose>
        <xsl:when test="($bSAOPropertyNumber='Y') and ($bPAODescription='N')">
          <xsl:value-of select="$SAOPropertyNumber"/>
        </xsl:when>
        <xsl:when test="($bSAOPropertyNumber='Y') and ($bPAODescription='Y')">
          <xsl:value-of select="$SAOPropertyNumber"/>, <xsl:value-of select="$PAODescription"/>
        </xsl:when>
        <xsl:when test="($bSAOPropertyNumber='N') and ($bPAODescription='Y')">
          <xsl:value-of select="$PAODescription"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="LineCount1">
      <xsl:choose>
        <xsl:when test="string-length($AddressLine1)=0">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="AddressLine2">
      <xsl:choose>
        <xsl:when test="$bPAOPropertyNumber='Y'">
          <xsl:value-of select="$PAOPropertyNumber"/>, <xsl:value-of select="$Street"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$Street"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="LineCount2">
      <xsl:choose>
        <xsl:when test="string-length($AddressLine2)=0">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="LineCount3">
      <xsl:choose>
        <xsl:when test="$bLocality='N'">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="LineCount4">
      <xsl:choose>
        <xsl:when test="$bTown='N'">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="LineCount5">
      <xsl:choose>
        <xsl:when test="($bAdministrativeArea='N') and ($bPostTown='N')">0</xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="LineCount">
      <xsl:number value="number($LineCount0) + number($LineCount1) + number($LineCount2) + number($LineCount3) + number($LineCount4) + number($LineCount5)"/>
    </xsl:variable>
    <xsl:variable name="AddressLine3">
      <!-- PAOPropertyNumber and Street have already been output in AddressLine 2 -->
      <!-- if there are more than 5 lines output loaclity & Town otherwise just Locality -->
      <xsl:choose>
        <xsl:when test="($bLocality='Y') and ($bTown='Y') and ($LineCount&gt;5)">
          <xsl:value-of select="$Locality"/>, <xsl:value-of select="$Town"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$bLocality='Y'">
              <xsl:value-of select="$Locality"/>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="AddressLine4">
      <xsl:choose>
        <xsl:when test="($bTown='Y') and ($LineCount&lt;6)">
          <xsl:value-of select="$Town"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="AddressLine5">
      <xsl:choose>
        <xsl:when test="($bAdministrativeArea='N') or (($bPostCode='Y') and ($bPostTown='Y'))">
          <xsl:value-of select="$PostTown"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$AdministrativeArea"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="string-length($AddressLine0)>0">
        <xsl:value-of select="$AddressLine0"/>
        <br />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="string-length($AddressLine1)>0">
        <xsl:value-of select="$AddressLine1"/>
        <br />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="string-length($AddressLine2)>0">
        <xsl:value-of select="$AddressLine2"/>
        <br />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="string-length($AddressLine3)>0">
        <xsl:value-of select="$AddressLine3"/>
        <br />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="string-length($AddressLine4)>0">
        <xsl:value-of select="$AddressLine4"/>
        <br />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="string-length($AddressLine5)>0">
        <xsl:value-of select="$AddressLine5"/>
        <xsl:if test="string-length($PCaddressLine)>0"><br /></xsl:if>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="string-length($PCaddressLine)>0">
        <xsl:value-of select="$PCaddressLine"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- template 'function' for returning distinct nodes in addresses -->
  <xsl:template name="distinct">
    <xsl:param name="nodes" select="/.." />
    <xsl:param name="distinct" select="/.." />
    <xsl:choose>
      <xsl:when test="$nodes">
        <xsl:call-template name="distinct">
          <xsl:with-param name="distinct" select="$distinct | $nodes[1][not(. = $distinct)]" />
          <xsl:with-param name="nodes" select="$nodes[position() > 1]" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$distinct" mode="distinct" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="node()|@*" mode="distinct">
    <xsl:for-each select="node()">
      <xsl:value-of select="normalize-space(.)" /><br />
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
