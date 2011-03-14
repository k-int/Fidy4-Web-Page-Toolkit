<%@ page import="java.util.*, java.text.*, java.net.*, java.io.*, java.lang.*, javax.xml.transform.*, org.w3c.dom.*, org.xml.sax.*, javax.xml.xpath.*, javax.xml.parsers.*, javax.xml.transform.stream.*, javax.xml.transform.dom.*" %>

<%!

public static class Helpers
{
    private static Helpers _instance;

    private Helpers()
    {
    }

    public static synchronized Helpers getInstance() {
        if (null == _instance) {
            _instance = new Helpers();
        }
        return _instance;
    }

    // URL of PKHD Aggregator server
    public static String root = "https://<aggregator_instance_in_here>";
	
	// API key for accessing PKHD Aggregator server
	public static String apikey = "";
	
    // Root directory where XSL files are located
	public static String xslRootPath = "templates_xsl/";
	
	// Custom page to show users when an error occurs
	public static String four0fourPage = xslRootPath + "custom404.html";

    // Define the id number of each controlled list (this allows a url to be built to retrieve the list)
    public static int langList = 10;               // Language list (ISO 639-1)
    public static int accreditList = 1;           // Accredidation list (Accreditation-1.0)
    public static int facilityList = 4;          // Facility Terms list 	(Facility 1.0)
    public static int ppaList = 6;               // Provision of Positive Activities 	(PPAYP-1.0)
    public static int qualityList = 7;           // Quality Assurance List 	(QualityAssurance-1.0)
    public static int referralList = 8;          // ReferralCriteria Terms List 	(ReferralCriteria 1.0)
    public static int rolesList = 9;             // Role list 	(Role 1.0)
    public static int spLevelsList = 2;           // Spatial Levels list 	(Spatial Levels 1.0)
    public static int accessChannelsList = 5;    // Local Government Channels-Terms list 	(LGCHL-1.01)
    public static int topCatsList = 11;           // PKH Mapped Vocabulary Version Ph3FINALV2 	(ISPP-001a-M)


    public static String redirectError(HttpServletResponse response, String errorMsg) {
		try{
			response.sendRedirect(Helpers.four0fourPage);
			return  errorMsg + "<br />";
		}
		catch (Exception e) {
			return "Generic Exception " + e + "<br />";
		}
	}


    public static String ReadFile(String urlString) {  
        StringBuffer buf = new StringBuffer("");
        try {  
            URL url = new URL(urlString);
            // Read all the text returned by the server  
            InputStreamReader reader = new InputStreamReader(url.openStream(), "ASCII");  
            BufferedReader in = new BufferedReader(reader);  
              
            String str;  
            while ((str = in.readLine()) != null) {                  
                buf.append(str);  
            }  
            in.close();  
        }  
        catch (IOException e) {  
            e.printStackTrace();  
        }  
        String rawVocab = buf.toString();
        String trimmed = "";
        if (0 < rawVocab.length()) {
            int dupPos = rawVocab.substring(5).indexOf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            trimmed = (0 < dupPos) ? rawVocab.substring(0,dupPos+5) : rawVocab;
        }
        return trimmed;
    }


    public static String loadAllCats()
    {
        String returnValue = "";
        try {
            DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
            ByteArrayInputStream baisLv1 = new ByteArrayInputStream(ReadFile(root + "/terminology/vocabs/" + topCatsList + "/topterms").getBytes());
            ByteArrayInputStream bais2Lv1 = new ByteArrayInputStream(ReadFile(root + "/terminology/vocabs/" + topCatsList + "/topterms").getBytes());
            Document allCategories = builder.parse(baisLv1);
            Document clone = builder.parse(bais2Lv1);
            NodeList level1IDs = clone.getElementsByTagName("internalId");
            for (int i=0; i<level1IDs.getLength(); i++) {
                String subcatPath = root + "/terminology/term/" + level1IDs.item(i).getFirstChild().getNodeValue() + "/children";
                ByteArrayInputStream baisLv2 = new ByteArrayInputStream(ReadFile(subcatPath).getBytes());
                Document vocab = builder.parse(baisLv2);

                // Identify the node in the original doc to hold data
                XPath xpath = XPathFactory.newInstance().newXPath();
                String expression = "topTerms/term[internalId = '" + level1IDs.item(i).getFirstChild().getNodeValue() + "']";
                Node termParent = (Node) xpath.evaluate(expression, allCategories, XPathConstants.NODE);

                // add data
                Element vocabTree = vocab.getDocumentElement();
                termParent.appendChild(allCategories.importNode(vocabTree, true));

                // Now get the 3rd-level category IDs
                NodeList level2IDs = vocab.getElementsByTagName("internalId");
                for (int j=0; j<level2IDs.getLength(); j++) {
                    String sub2catPath = root + "/terminology/term/" + level2IDs.item(j).getFirstChild().getNodeValue() + "/children";
                    // Check if there are any 3rd-level categories
                    String sub2catXML = ReadFile(sub2catPath);
                    if (false == sub2catXML.equals(""))
                    {
                        ByteArrayInputStream baisLv3 = new ByteArrayInputStream(sub2catXML.getBytes());
                        Document vocab2 = builder.parse(baisLv3);

                        // Identify the node in the original doc to hold data
                        XPath xpath2 = XPathFactory.newInstance().newXPath();
                        String expression2 = "topTerms/term[internalId = " + level1IDs.item(i).getFirstChild().getNodeValue() + "]/termChildren/term[internalId = " + level2IDs.item(j).getFirstChild().getNodeValue() + "]";
                        Node term2Parent = (Node) xpath2.evaluate(expression2, allCategories, XPathConstants.NODE);

                        // add data
                        Element vocab2Tree = vocab2.getDocumentElement();
                        term2Parent.appendChild(allCategories.importNode(vocab2Tree, true));
                    }
                }
            }
            try {
                Source source = new DOMSource(allCategories);
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                Result result = new StreamResult(baos);
                TransformerFactory factory = TransformerFactory.newInstance();
                Transformer transformer = factory.newTransformer();
                transformer.transform(source, result);
                returnValue = baos.toString();
            } catch (TransformerConfigurationException e) {
                e.printStackTrace();
            } catch (TransformerException e) {
                e.printStackTrace();
            }
        }
        catch (ParserConfigurationException pe) {
            returnValue = "Parser Exception - " + pe.getMessage();
        }
        catch (NullPointerException n) {
            returnValue = "Null Pointer Exception ("+n.getCause()+") - " + n.toString();
        }
        catch (Exception e) {
            returnValue = "General Exception ("+e.getCause()+") - " + e.toString();
        }

        return returnValue;
    }


    public static Transformer setToolkitParameters(Transformer optimus) {
        optimus.setParameter("homepage", "search.jsp");
        optimus.setParameter("directoryPage", "directory.jsp");
        optimus.setParameter("indexPage", "subject_index.jsp");
        optimus.setParameter("advsearchPage", "advanced_search.jsp");
        optimus.setParameter("resultsPage", "results.jsp");
        optimus.setParameter("locationPage", "specify_location.jsp");
        optimus.setParameter("detailsPage", "details.jsp");
        optimus.setParameter("resourcesFolder", "/templates/");
        optimus.setParameter("imagesFolder", "/images/");
        optimus.setParameter("stylesFolder", "/styles/");
        optimus.setParameter("scriptsFolder", "/scripts/");
        optimus.setParameter("mapType", "google");
        optimus.setParameter("mapAPI", "http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAC6OpstQ6kPTRjguiItFOrxTkKg7oYb-VdK4ySCurh20P8-VaFRQ-z_m-tjdMgCWAnpYKL4b_OOTzDg");
        return optimus;
    }


    public static String HTMLEncode(String s) {

        final char c[] = { '<', '>', '&', '\"', '\u0093', '\''};
        final String expansion[] = {"&lt;", "&gt;", "&amp;", "&quot;", "&pound;", "&apos;"};
        StringBuffer st = new StringBuffer();
        for (int i = 0; i < s.length(); i++) {
            boolean copy = true;
            char ch = s.charAt(i);
            for (int j = 0; j < c.length ; j++) {
                if (c[j]==ch) {
                    st.append(expansion[j]);
                    copy = false;
                    break;
                }
            }
            if (copy) st.append(ch);
        }
        return st.toString();
    }


} // end Class


%>

<%

      if (null == application.getAttribute("langList")) {
	      application.setAttribute("langList", Helpers.ReadFile(Helpers.root + "/terminology/vocabs/" + Helpers.langList + "/topterms"));
      }
      if (null == application.getAttribute("accessChannelsList")) {
	      application.setAttribute("accessChannelsList", Helpers.ReadFile(Helpers.root + "/terminology/vocabs/" + Helpers.accessChannelsList + "/topterms"));
      }
      if (null == application.getAttribute("referralList")) {
	      application.setAttribute("referralList", Helpers.ReadFile(Helpers.root + "/terminology/vocabs/" + Helpers.referralList + "/topterms"));
      }
      if (null == application.getAttribute("topCatsList")) {
	      application.setAttribute("topCatsList", Helpers.ReadFile(Helpers.root + "/terminology/vocabs/" + Helpers.topCatsList + "/topterms"));
      }
      if (null == application.getAttribute("fullCatsList")) {
	      application.setAttribute("fullCatsList", Helpers.loadAllCats());
      }

	
%>