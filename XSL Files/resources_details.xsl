<xsl:stylesheet version="1.0"	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:ecdrec="http://dcsf.gov.uk/XMLSchema/Childcare"
								xmlns:fsdrec="http://dcsf.gov.uk/XMLSchema/ServiceDirectory"
								xmlns:srw="http://www.loc.gov/zing/srw/"
                xmlns:facet="http://k-int.com/facet"
								xmlns:jzkit="http://www.k-int.com/jzkit/"
								xmlns:apd="http://www.govtalk.gov.uk/people/AddressAndPersonalDetails"
								xmlns:con="http://www.govtalk.gov.uk/people/ContactTypes"
								xmlns:bs7666="http://www.govtalk.gov.uk/people/bs7666">

  <xsl:import href="resources_utilities.xsl" />
  <xsl:output method="html" encoding="utf-8" indent="yes" />

  <xsl:variable name="showMap" select="'yes'" />

  <xsl:variable name="catList" select="/*/controlledListData/catsList/topTerms" />

  <!-- logic to determine the record type -->
  <xsl:variable name="recordType">
    <xsl:choose>
      <xsl:when test="/fsdrec:ServiceDescription != not(*)">
        <xsl:value-of select="string(/fsdrec:ServiceDescription/echoedData/queryString/@recordType)" />
      </xsl:when>
      <xsl:when test="/ecdrec:ProviderDescription != not(*)">
        <xsl:value-of select="string(/ecdrec:ProviderDescription/echoedData/queryString/@recordType)" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- R09:  Code required for tab tool start -->
  <xsl:variable name="view">
    <xsl:choose>
      <xsl:when test="'FSD' = $recordType">
        <xsl:value-of select="string(/fsdrec:ServiceDescription/echoedData/queryString/@view)" />
      </xsl:when>
      <xsl:when test="'ECD' = $recordType">
        <xsl:value-of select="string(/ecdrec:ProviderDescription/echoedData/queryString/@view)" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <!-- R09:  Code required for tab tool end -->

  <xsl:variable name="print">
    <xsl:choose>
      <xsl:when test="'FSD' = $recordType">
        <xsl:value-of select="string(/fsdrec:ServiceDescription/echoedData/displayType)" />
      </xsl:when>
      <xsl:when test="'ECD' = $recordType">
        <xsl:value-of select="string(/ecdrec:ProviderDescription/echoedData/displayType)" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Check provision (it's quicker to define them once here than to check the tree each time) -->
  <xsl:variable name="wheelchair">
    <xsl:choose>
      <xsl:when test="'FSD' = $recordType">
        <xsl:value-of select="string(/fsdrec:ServiceDescription/fsdrec:SpecialProvisions/fsdrec:WheelchairAccess/@HasProvision)" />
      </xsl:when>
      <xsl:when test="'ECD' = $recordType">
        <xsl:value-of select="string(/ecdrec:ProviderDescription/ecdrec:ProviderDetails/ecdrec:SpecialProvisions/ecdrec:WheelchairAccess/@HasProvision)" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="cultural">
    <xsl:choose>
      <xsl:when test="'FSD' = $recordType">
        <xsl:value-of select="string(/fsdrec:ServiceDescription/fsdrec:SpecialProvisions/fsdrec:CulturalProvision/@HasProvision)" />
      </xsl:when>
      <xsl:when test="'ECD' = $recordType">
        <xsl:value-of select="string(/ecdrec:ProviderDescription/ecdrec:ProviderDetails/ecdrec:SpecialProvisions/ecdrec:CulturalProvision/@HasProvision)" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="dietary">
    <xsl:choose>
      <xsl:when test="'FSD' = $recordType">
        <xsl:value-of select="string(/fsdrec:ServiceDescription/fsdrec:SpecialProvisions/fsdrec:SpecialDiet/@HasProvision)" />
      </xsl:when>
      <xsl:when test="'ECD' = $recordType">
        <xsl:value-of select="string(/ecdrec:ProviderDescription/ecdrec:ProviderDetails/ecdrec:SpecialProvisions/ecdrec:SpecialDiet/@HasProvision)" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="specneeds">
    <xsl:choose>
      <xsl:when test="'FSD' = $recordType">
        <xsl:value-of select="string(/fsdrec:ServiceDescription/fsdrec:SpecialProvisions/fsdrec:SpecialNeeds/@HasProvision)" />
      </xsl:when>
      <xsl:when test="'ECD' = $recordType">
        <xsl:value-of select="string(/ecdrec:ProviderDescription/ecdrec:ProviderDetails/ecdrec:SpecialProvisions/ecdrec:SpecialNeeds/@HasProvision)" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="vacancies" select="string(/ecdrec:ProviderDescription/ecdrec:ProviderDetails/ecdrec:ImmediateVacancies)" />
  <xsl:variable name="pickup" select="string(/ecdrec:ProviderDescription/ecdrec:ProviderDetails/ecdrec:Pickups/@HasProvision)" />


  <xsl:template name="catLister">
    <xsl:param name="id" />
    <xsl:param name="conceptId" />
    <xsl:variable name="parent" select="//term[identifier = $id]/../.." />
    <xsl:if test="0 &lt; string-length($parent/../../name)">
      <xsl:choose>
        <xsl:when test="'print' != $print">
          <a href="{$resultsPage}?category={$parent/../../identifier}">
            <xsl:value-of select="$parent/../../name" />
          </a> &gt;
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$parent/../../name" /> &gt;
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>


    <xsl:if test="string-length($conceptId) &gt; 0">
      <xsl:if test="0 &lt; string-length($parent/name)">
        <xsl:variable name="concept" select="//term[identifier = $conceptId]" />
        <xsl:choose>
          <xsl:when test="'print' != $print">
            <a>
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="0 &lt; string-length($parent/../../name)">
                    <xsl:value-of select="concat($resultsPage, '?category=', $parent/../../identifier, '&amp;subcategory=', $concept/identifier)" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($resultsPage, '?category=', $concept/identifier)" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="$concept/name" />
            </a> &gt;
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$concept/name" /> &gt;
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="0 &lt; string-length($parent/../../name)">
          <xsl:choose>
            <xsl:when test="'print' != $print">
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="concat($resultsPage, '?category=', $parent/../../identifier, '&amp;subcategory=', $parent/identifier, '&amp;subsubcategory=', $id)" />
                </xsl:attribute>
                <xsl:value-of select="."/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="." />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="0 &lt; string-length($parent/name)">
          <xsl:choose>
            <xsl:when test="'print' != $print">
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="concat($resultsPage, '?category=', $conceptId, '&amp;subcategory=', $id)" />
                </xsl:attribute>
                <xsl:value-of select="."/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="." />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="string-length($conceptId) = 0">
      <xsl:if test="0 &lt; string-length($parent/name)">
        <xsl:choose>
          <xsl:when test="'print' != $print">
            <a>
              <xsl:attribute name="href">
                <xsl:choose>
                  <xsl:when test="0 &lt; string-length($parent/../../name)">
                    <xsl:value-of select="concat($resultsPage, '?category=', $parent/../../identifier, '&amp;subcategory=', $parent/identifier)" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat($resultsPage, '?category=', $parent/identifier)" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:value-of select="$parent/name" />
            </a> &gt;
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$parent/name" /> &gt;
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="0 &lt; string-length($parent/../../name)">
          <xsl:choose>
            <xsl:when test="'print' != $print">
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="concat($resultsPage, '?category=', $parent/../../identifier, '&amp;subcategory=', $parent/identifier, '&amp;subsubcategory=', $id)" />
                </xsl:attribute>
                <xsl:value-of select="."/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="." />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="0 &lt; string-length($parent/name)">
          <xsl:choose>
            <xsl:when test="'print' != $print">
              <a>
                <xsl:attribute name="href">
                  <xsl:value-of select="concat($resultsPage, '?category=', $parent/identifier, '&amp;subcategory=', $id)" />
                </xsl:attribute>
                <xsl:value-of select="."/>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="." />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>



  <!-- template 'function' for creating address -->
  <xsl:template match="*['Address'=local-name() or 'PostalAddress'=local-name()]" mode="fullAddress">
    <xsl:choose>
      <xsl:when test=". != not(*)">
        <xsl:if test="apd:BS7666Address">
          <xsl:apply-templates select="apd:BS7666Address" />
        </xsl:if>
        <xsl:if test="apd:A_5LineAddress">
          <xsl:for-each select="apd:A_5LineAddress/apd:Line">
            <xsl:value-of select="." />
            <br />
          </xsl:for-each>
          <xsl:value-of select="apd:A_5LineAddress/apd:PostCode" />
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <i>We do not have address details for this service</i>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- template 'function' for creating phone numbers (FSD records) -->
  <xsl:template match="*['ContactNumber'=local-name()]">
    <p>
      <span class="profileLabel">
        <xsl:choose>
          <xsl:when test="@Type">
            <xsl:call-template name="capitalise">
              <xsl:with-param name="source" select="@Type" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>Telephone</xsl:otherwise>
        </xsl:choose>:
      </span>
      <xsl:value-of select="apd:TelNationalNumber" />
      <xsl:if test="@TelUse">
        (<xsl:value-of select="@TelUse" /><xsl:if test="@TelMobile = 'yes'"> - mobile</xsl:if>)
      </xsl:if>
    </p>
  </xsl:template>

  <!-- template 'function' for creating phone numbers (ECD records) -->
  <xsl:template match="*['TelephoneNumber'=local-name()]">
    <p>
      <span class="profileLabel">
        <xsl:choose>
          <xsl:when test="@Type">
            <xsl:call-template name="capitalise">
              <xsl:with-param name="source" select="@Type" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>Telephone</xsl:otherwise>
        </xsl:choose>:
      </span>
      <xsl:value-of select="apd:TelNationalNumber" />
      <xsl:if test="@TelUse">
        (<xsl:value-of select="@TelUse" /><xsl:if test="@TelMobile = 'yes'"> - mobile</xsl:if>)
      </xsl:if>
    </p>
  </xsl:template>

  <!-- template 'function' for creating fax numbers (ECD records) -->
  <xsl:template match="*['FaxNumber'=local-name()]">
    <xsl:if test="string-length(apd:FaxNationalNumber) &gt; 0">
      <p>
        <span class="profileLabel">
          <xsl:choose>
            <xsl:when test="@Type">
              <xsl:call-template name="capitalise">
                <xsl:with-param name="source" select="@Type" />
              </xsl:call-template>:
            </xsl:when>
            <xsl:otherwise>
              Fax:
            </xsl:otherwise>
          </xsl:choose>
        </span>
        <xsl:value-of select="apd:FaxNationalNumber" />
        <xsl:if test="@FaxUse">
          (<xsl:value-of select="@FaxUse" /><xsl:if test="@FaxMobile = 'yes'"> - mobile</xsl:if>)
        </xsl:if>
      </p>
    </xsl:if>
  </xsl:template>

  <!-- template 'function' for creating email address -->
  <xsl:template match="*['EmailAddress'=local-name()]">
    <p>
      <span class="profileLabel">Email: </span>
      <xsl:value-of select="apd:EmailAddress" />
      <xsl:if test="@EmailUsage">
        (<xsl:value-of select="@EmailUsage" />)
      </xsl:if>
    </p>
  </xsl:template>

  <!-- template 'function' for creating website address -->
  <xsl:template match="*['WebsiteAddress'=local-name()]">
    <xsl:variable name="website">
      <xsl:if test="starts-with(., 'http://') != 'true'">http://</xsl:if>
      <xsl:value-of select="." />
    </xsl:variable>
    <p>
      <span class="profileLabel">Web site: </span><a href="{$website}" target="_blank">
        <xsl:value-of select="." />
      </a> (opens new window)
    </p>
  </xsl:template>

  <!-- template 'function' for creating entries in the See Also box -->
  <!-- F10:  Code required for see also tool start -->
  <!-- logic to determine the category (if selected) -->
  <xsl:variable name="chosenCategory">
    <xsl:choose>
      <xsl:when test="'FSD' = $recordType">
        <xsl:value-of select="string(/fsdrec:ServiceDescription/echoedData/queryString/@category)" />
      </xsl:when>
      <xsl:when test="'ECD' = $recordType">
        <xsl:value-of select="string(/ecdrec:ProviderDescription/echoedData/queryString/@category)" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:template name="seeAlso">
    <xsl:param name="data" />
    <xsl:variable name="recordType" select="substring(normalize-space($data/arr[@name = 'repo_url_s']/str), string-length(normalize-space($data/arr[@name = 'repo_url_s']/str))-2)" />
    <xsl:variable name="website">
      <xsl:value-of select="concat($detailsPage, '?recordID=', normalize-space($data/str['aggregator.internal.id' = @name]), '&amp;recordType=', $recordType, '&amp;category=', $chosenCategory)" />
    </xsl:variable>
    <p class="seeAlsoLink">
      <a href="{$website}">
        <xsl:value-of select="normalize-space($data/arr['dc.title' = @name]/str)" />
      </a>
    </p>
    <p class="seeAlsoDesc">
      <xsl:choose>
        <xsl:when test="50 &lt; string-length($data/arr['dc.description' = @name]/str)">
          <xsl:value-of select="substring(normalize-space($data/arr['dc.description' = @name]/str), 0, 47)" />...
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($data/arr['dc.description' = @name]/str)" />
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>
  <!-- F10:  Code required for see also tool end -->

  <!-- Suppress all text nodes by default (prevents extra xml content being written to screen) -->
  <xsl:template match="text()" />

</xsl:stylesheet>
