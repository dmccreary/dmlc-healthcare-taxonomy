<?xml version="1.0" encoding="us-ascii"?>
<!--
The contents of this file are subject to the Health Level-7 Public
License Version 1.0 (the "License"); you may not use this file
except in compliance with the License. You may obtain a copy of the
License at http://www.hl7.org/HPL/hpl.txt.

Software distributed under the License is distributed on an "AS IS"
basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
the License for the specific language governing rights and
limitations under the License.

The Original Code is all this file.

The Initial Developer of the Original Code is Gunther Schadow,
Pragmatic Data LLC. Portions created by Initial Developer are
Copyright (C) 2002-2013 Health Level Seven, Inc. All Rights Reserved.
-->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:v3="urn:hl7-org:v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="v3 xsl">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes" />
	<xsl:strip-space elements="*" />
	
	<xsl:template match="/">
		<xsl:apply-templates mode="substance" select="." />
	</xsl:template>
	
	<xsl:template match="v3:code[@codeSystem='2.16.840.1.113883.4.9']/@code" mode="substance">
		<xsl:text>(</xsl:text>
		<xsl:value-of select="." />
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	<xsl:template match="v3:value[contains(@mediaType, 'x-mdl-molfile') or contains(@mediaType, 'x-smiles') and parent::v3:characteristic/parent::v3:subjectOf]" mode="mol2img">
		<pre>
			<xsl:copy-of select="text()"/>
		</pre>
	</xsl:template>
	
	<xsl:template match="v3:asNamedEntity" mode="substance">
		<xsl:if test="position() = 1">	
			<tr>
				<td colspan="3" class="formHeadingTitle">Alias Name</td>
			</tr>
			<tr>
				<th class="formTitle" scope="col">Name</th>
				<th class="formTitle" scope="col">Name Type</th>
				<th class="formTitle" scope="col">Reference Document</th>
			</tr>
		</xsl:if>	
		<tr>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
					<xsl:otherwise>formTableRowAlt</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<td class="formItem" style="width: 70%;">
				<xsl:value-of select="v3:name"/>
			</td>
			<td class="formItem">
				<xsl:value-of select="v3:code/@code"/>
			</td>
			<td class="formItem">
				<xsl:value-of select="v3:subjectOf/v3:document/v3:title"/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="v3:asSpecializedKind/v3:generalizedMaterialKind|v3:asEquivalentSubstance/v3:definingSubstance" mode="substance">
		<tr class="formTableRowAlt">							
			<td class="formLabel">
				<xsl:if test="parent::v3:asSpecializedKind">Classification</xsl:if>
				<xsl:if test="parent::v3:asEquivalentSubstance">Mapping</xsl:if>
			</td>
			<td class="formLabel">Name:</td>
			<td class="formItem">
				<xsl:value-of select="v3:code/@displayName"/>
			</td>
			<td class="formLabel">
				<xsl:choose>
					<xsl:when test="v3:code/@codeSystem = '2.16.840.1.113883.3.26.1.5'">NDF-RT:</xsl:when>
					<xsl:when test="v3:code/@codeSystem = '1.3.6.1.4.1.5193'">CAS:</xsl:when>
					<xsl:when test="v3:code/@codeSystem = '2.16.840.1.113883.3.2705'">Definition Hash:</xsl:when>
					<xsl:otherwise>
						<xsl:text>System:</xsl:text>
						<xsl:value-of select="v3:code/@codeSystem"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>			
			<td class="formItem">	
				<xsl:value-of select="v3:code/@code"/>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="v3:moiety" mode="substance">
		<tr>
			<td colspan="4">
				<table width="100%" cellpadding="5" cellspacing="0" class="formTablePetite">
					
					<tr>
						<td colspan="4" class="formHeadingTitle">
							<xsl:if test="parent::v3:partMoiety/parent::v3:moiety">
								<xsl:value-of select="concat('Part',count(preceding-sibling::v3:moiety)+1)"/>
							</xsl:if>
							<xsl:text>Moiety </xsl:text>
							<xsl:for-each select="v3:code/@displayName">(<xsl:value-of select="."/>)</xsl:for-each>
							<xsl:for-each select="v3:partMoiety/v3:id/@extension"> Id:<xsl:value-of select="."/></xsl:for-each>
						</td>
					</tr>
					<tr class="formTableRowAlt">
						<td class="formLabel">Name</td>
						<td class="formItem">
							<xsl:value-of select="v3:partMoiety/v3:name"/>
						</td>
						<td class="formLabel">Quantity</td>
						<td class="formItem">
							<xsl:choose>
								<xsl:when test="v3:quantity/v3:numerator[v3:low[@value = '0' and @inclusive = 'true']]">
									<xsl:text>Undefined, may be 0</xsl:text>
								</xsl:when>
								<xsl:when test="v3:quantity/v3:numerator[v3:low[@value = '0' and @inclusive = 'false']]">
									<xsl:text>Undefined not 0</xsl:text>
								</xsl:when>
								<xsl:when test="v3:quantity/v3:numerator[not(v3:low and v3:high)]">
									<xsl:value-of select="v3:quantity/v3:numerator/@value"/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:numerator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:numerator/@unit"/></xsl:if>
									<xsl:if test="(v3:quantity/v3:denominator/@value and normalize-space(v3:quantity/v3:denominator/@value)!='1') 
																or (v3:quantity/v3:denominator/@unit and normalize-space(v3:quantity/v3:denominator/@unit)!='1')"> &#160;in&#160;<xsl:value-of select="v3:quantity/v3:denominator/@value"
																/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:denominator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:denominator/@unit"/>
									</xsl:if></xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="v3:quantity/v3:numerator/v3:low/@value"/>-<xsl:value-of select="v3:quantity/v3:numerator/v3:high/@value"/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:numerator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:numerator/v3:low/@unit"/></xsl:if>
									<xsl:if test="(v3:quantity/v3:denominator/@value and normalize-space(v3:quantity/v3:denominator/@value)!='1') 
																or (v3:quantity/v3:denominator/@unit and normalize-space(v3:quantity/v3:denominator/@unit)!='1')"> &#160;in&#160;<xsl:value-of select="v3:quantity/v3:denominator/@value"
																/>&#160;<xsl:if test="normalize-space(v3:quantity/v3:denominator/@unit)!='1'"><xsl:value-of select="v3:quantity/v3:denominator/@unit"/>
									</xsl:if></xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<!--Substituent Table-->
					<xsl:if test="v3:partMoiety/v3:bond[v3:distalMoiety/v3:code/@code]">
						<tr>		
							<td colspan="4">
								<table width="100%" cellpadding="5" cellspacing="0">
									<tr>
										<td colspan="4" class="formHeadingTitle">Substituent Information</td>
									</tr>
									<tr class="fromTableRowAlt">
										<th class="formTitle" scope="col">Substituent Type</th>
										<th class="formTitle" scope="col">Position</th>
										<th class="formTitle" scope="col">Code Name</th>
										<th class="formTitle" scope="col">Code System</th>
									</tr>
									<xsl:apply-templates mode="substance" select="v3:partMoiety/v3:bond[v3:distalMoiety/v3:code/@code]"></xsl:apply-templates>
								</table>	
							</td>
						</tr>
					</xsl:if>	
					<!--Here comes the Moiety Characteristics.-->
					<tr>
						<td colspan="4">
							<table width="100%" cellpadding="3" cellspacing="0" >
								<xsl:apply-templates mode="substance" select="v3:subjectOf/v3:characteristic"/>
							</table>
						</td>
					</tr>
					
					<xsl:apply-templates mode="substance" select="v3:partMoiety/v3:moiety"/>
					
				</table>
			</td>
		</tr>
	</xsl:template>
	
	<!--Linkage Table-->
	<xsl:template  mode="substance" match="v3:bond[v3:distalMoiety/v3:id/@extension]">
		<tr class="formTableRowAlt">				
			<td  class="formLabel">
				<xsl:text>A</xsl:text>&#160;<xsl:value-of select="v3:code/@displayName"></xsl:value-of>&#160;<xsl:text>between moiety</xsl:text>&#160;<xsl:value-of select="../v3:id/@extension"></xsl:value-of>&#160;<xsl:text>and</xsl:text>&#160;<xsl:value-of select="v3:distalMoiety/v3:id/@extension"></xsl:value-of>
			</td>
			<td class="formLabel">Position Number</td>
			<td>
				<xsl:value-of select="v3:positionNumber[position() = 1]/@value"></xsl:value-of><xsl:text>,</xsl:text><xsl:value-of select="v3:positionNumber[position() = last()]/@value"></xsl:value-of>
			</td>
		</tr>
	</xsl:template>

	<!--Substituent Table-->
	<xsl:template mode="substance" match="v3:partMoiety/v3:bond[v3:distalMoiety/v3:code/@code]">
		<tr class="formTableRowAlt">	
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="position() mod 2 = 0">formTableRow</xsl:when>
					<xsl:otherwise>formTableRowAlt</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<td class="formItem">
				<xsl:value-of select="v3:code/@displayName"></xsl:value-of>
			</td>
			<td class="formItem">
				<xsl:for-each select="v3:positionNumber/@value">
					<xsl:value-of select="."></xsl:value-of>
					<xsl:if test="position()!=last()">,</xsl:if>
				</xsl:for-each>
			</td>
			<td class="formItem">
				<xsl:value-of select="v3:distalMoiety/v3:name|v3:distalMoiety/v3:code/@displayName"/>
			</td>
			<td class="formItem">
				<xsl:choose>
					<xsl:when test="v3:distalMoiety/v3:code/@codeSystem = '2.16.840.1.113883.4.9'">UNII</xsl:when>
					<xsl:when test="v3:distalMoiety/v3:code/@codeSystem = '2.16.840.1.113883.3.26.1.1'">NCI</xsl:when>
					<xsl:otherwise>Atom Symbol</xsl:otherwise>
				</xsl:choose>
				&#160;<xsl:text>:</xsl:text>&#160;<xsl:value-of select="v3:distalMoiety/v3:code/@code"/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="v3:productOf/v3:derivationProcess|v3:interactsIn/v3:interaction" mode="substance">
		<tr class="formTableRowAlt">							
			<td class="formLabel">
				<xsl:if test="parent::v3:productOf">Derivation</xsl:if>
				<xsl:if test="parent::v3:interactsIn">Interaction</xsl:if>
			</td>
			<td class="formLabel">Name:</td>
			<td class="formItem">
				<xsl:value-of select="v3:code/@displayName"/>
				<xsl:if test="normalize-space(v3:code/@code)">
					(<xsl:value-of select="v3:code/@code"/>)
				</xsl:if>
			</td>
			<td class="formLabel">
				Substance Name:
			</td>			
			<td class="formItem">	
				<xsl:value-of select="v3:interactor/v3:identifiedSubstance/v3:name"/>
				<xsl:if test="normalize-space(v3:interactor/v3:identifiedSubstance/v3:code/@code)">
					(<xsl:value-of select="v3:interactor/v3:identifiedSubstance/v3:code/@code"/>)
				</xsl:if>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="v3:subjectOf/v3:characteristic" mode="substance">
		<xsl:if test="position() = 1">
			<tr>
				<td colspan="4" class="formHeadingTitle">
					<!-- Need to support this template for Substituent -->
					<xsl:if test="parent::v3:subjectOf/parent::v3:identifiedSubstance">Substance</xsl:if>
					<xsl:if test="parent::v3:subjectOf/parent::v3:moiety">Moiety</xsl:if>
					&#160;Characteristics
				</td>
			</tr>
		</xsl:if>
		<tr class="formTableRowAlt">
			<td class="formLabel" style="width: 80%;">
				<xsl:value-of select="v3:code/@displayName"/>
				<xsl:choose>
					<xsl:when test="v3:value[@mediaType='application/x-inchi']">
						<xsl:text>s, InChI</xsl:text>
					</xsl:when>
					<xsl:when test="v3:value[@mediaType='application/x-inchi-key']">
						<xsl:text>, InChI Key</xsl:text>
					</xsl:when>
					<xsl:when test="v3:value[@mediaType='application/x-mdl-molfile']">
						<xsl:text>, MOLFILE</xsl:text>
					</xsl:when>
				</xsl:choose>
			</td>
			<!-- Added word-break to hide the Horizontal scroll bar in FF -->
			<td class="formItem" style="word-break: break-all;">
				<xsl:choose>
					<xsl:when test="v3:value[@xsi:type='ED' and contains(@mediaType, 'x-mdl-molfile') or contains(@mediaType, 'x-smiles')]">
						<xsl:apply-templates mode="mol2img" select="v3:value"/>
					</xsl:when>	
					<xsl:when test="v3:value[@xsi:type='ED' and contains(@mediaType, 'x-inchi') or contains(@mediaType, 'x-inchi-key')]">
						<xsl:value-of select="v3:value"/>
					</xsl:when>
					<xsl:when test="v3:value[@xsi:type='CV']">
						<xsl:value-of select="v3:value/@displayName"/>
						<xsl:if test="v3:value/@code and not(v3:value/@displayName)">
							<xsl:value-of select="v3:value/@code"/>
							<xsl:for-each select="v3:value/@codeSystem"> System: <xsl:value-of select="."/></xsl:for-each>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="v3:value/@value"/>
						<xsl:for-each select="v3:value/@unit"><xsl:text> </xsl:text><xsl:value-of select="."/></xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>	
			</td>
		</tr>	
	</xsl:template>
</xsl:transform>
