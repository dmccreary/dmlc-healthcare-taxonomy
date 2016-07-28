Release Notes

SPL Stylesheet Revision 5.9

 * Support for Wholesale Drug Distributor/Third Party Logistics
   Provider Reporting SPL 
 * Support for Human Compounded drug label.
 * Correction for Combination product category data element rendering
 * Support for Lot Distribution Data SPL
 * Resolved Core SPL Stylesheet Error on AccessData?
 * Corrected: text elements nested deep in product data elements were
   rendered as section text, only render section text that way.
 * Fixed stylesheet display pattern for package characteristics.
 * For indexing files, showing displayName
 * Resolved stylesheet issue for rendering of Disclaimers
 * Excludes subsection of section 17 from the TOC
 * Correct the sorting of timestamps
 * Display of UNII in product data element section


SPL Stylesheet Revision 5.8
 
 * Added support for Substance Indexing
 * Render Marketing Start Date and End Date at the package level in
   the package table.
 * Exclude sections after Section 17 from the FPI table of contents.
 * Rendering of most recent highlights text revision date excluding
	* Data Elements Section and all sections past section 17.
    * No preceding zero if the month is a single digit. 
     For example: Revision Date: 4/2013
 * Support the Labeler Code Request - Animal Drug
 * Support use of Labeler Code Request Labeler Detail Information data elements
 * For 508 complience, add column and row tagging for tabular data elements
   i.e., those tables which are data tables, not just for layout.
 * Medical foods erroneously had a disclaimer.
 * Allow hiding (toggle show/hide) the Core Content of Labeling
   "mixin" (e.g., for PET drugs)
 * Minor CSS stylesheet improvement, turning solid white background
   into transparent background.
 
SPL Stylesheet Revision 5.7

 * Fixed change bar in certain itemized lists

SPL Stylesheet Revision 5.6

 * ISBT support
 * Fax Number Support in GDUFA files
 * 508 compliance improved for data element tables
 * fixes for display of certain marketing categories (dietary supplement)

SPL Stylesheet Revision 5.5

 * Added support for GDUFA.
 * Removed recent major changes from TOC.
 * Added border left for all recent major changes (for elements having @stylecode = 'xmChange')
 * Added support for contaminant and other ingredients.
 * Resolved the issues of auto section numbering where it produced high numbers.
 * Removed display of pharmacologic class for devices and properly show the device "product code".

SPL Stylesheet Revision 5.4p2

 * support for 2-column style of highlights and TOC for all browsers
 * various minor layout improvement to be more similar to the FDA
   approved labels (this is still ongoing work.)

SPL Stylesheet Revision 5.4p1

 * fixed a typo in the document type list
 * numbered lists were not indented properly

SPL Stylesheet Revision 5.4
 
 * remove multilevel packaging column altogether
 * fix boldface style for the See 17 for ... references
 * fix boldface style for the highlights revision date 
 * allow user to introspect the document id, set id, version metadata 
   by hovering over the last "Revised: MM/YYYY" statement at the very
   end of the document (this is using CSS only, no scripts.)
 * turn off browser quirksmode by inserting a DOCTYPE element and make
   CSS stylesheet behavior more predictable.

SPL Stylesheet Revision 5.3p5

Defect Fixes (p1, p2, p3, p4, p5):

 * multilevel packaging should only mention outer packages in the 
   same lineage
 * missing display "plasma derivative" as a product type
 * unapproved medical gas disclaimer was missing
 * the list of packages under kits included packages under parts.
 * observationMedia text was rendered as if it was section text
 * no auto-generated links in highlights only if any linkHtml exists
 * missing document type in title position for non product SPLs.
 * packaging list in order of outer to inner package

Enhancements:

 * special handling of BPCA statements in highlights
 * special handling of added rendering of microbiology in subsection
 * more compact display of establishment-product relationships

Problems Fixed:

 * resolved defect where nested highlight sections/subsections were not
   displayed in correct order
 * resolved defect where packaging hierarchy was not displayed properly

Experimental Features:

 * experimental support for foods
 * experimental lot distribution report display
 * devices (still experimental) fix display of NDC codes as NDC vs. NHRIC 
 * CSS3 based two column format removed as it would not work on all browsers

SPL Stylesheet Revision 5.0 

This stylesheet release includes some major changes in what is visible
as well as changes in the code organizations.

Enhancements:

 * processing of core SPL files
 * adding disclaimers for various marketing categories
 * add support for devices
   * show code system for product and package codes 
   * handle more characteristics
 * highlights now show in two-column format using CSS3 multicolumn
   module (on Firefox and WebKit browsers (Google Chrome and Safari)
 * as originally designed, add the main section reference to highlight
   item if last paragraph does not already contains such a reference
 * the underlined template text has been removed, no more underline
 * the print CSS uses 10pt base and 8pt highlights to permit
   verification of the highlights size restriction.

Internal Modifications:

 * internal cleanup of code

Problems Fixed:

 * @styleCode attribute was output after the <a name.../> element
   which caused XSLT errors
 * title was repeated and failed if there was markup with @styleCode
   in it
 * @xmChange span was incorrectly inserted before the processing of
   attributes, leading to stylesheet error in browser 
 * pharmacologic class templates fixed
 * encoding specified correctly on spl.xsl
 * added number function call to avoid transform "cannot convert
   string to long" exception
 * resolved bug in Safari with footnote placement

Other Changes:

 * stopped support for the FO transforms and removed related files
   from the release.
