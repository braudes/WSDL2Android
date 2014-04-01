package ${package};

<#if importBindings??>import ${importBindings}.*;</#if>
import org.xmlpull.v1.XmlSerializer;
import java.io.IOException;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import java.util.List;
import java.util.ArrayList;

public class ${typeName} extends SOAPObject 
{
    <#if atts??>
    <#list atts as att>
    public ${att.javaType} ${att.name} = null;
    </#list>
    </#if>

    <#if elements??>
    <#list elements as element>
    <#if element.maxOccurs != 1>
    public List<${element.javaType}> _${element.name} = new ArrayList<${element.javaType}>();
    <#else>
    public ${element.javaType} _${element.name} = null;
    </#if>
    </#list>
    </#if>

    public String getNamespace()
    {
        return "<#if namespace??>${namespace}</#if>";
    }

    public void addAttributesToNode(XmlSerializer xml) throws IOException
    {
        <#if atts??>
        <#list atts as att>
        if(${att.name} != null)
        {
            xml.attribute(null, "${att.name}", ${att.name}.toString());
        }
        </#list>
        </#if>
    }

    public void addElementsToNode(XmlSerializer xml) throws IOException
    {
        <#if elements??>
        <#list elements as element>
        if(_${element.name} != null)
        {
        <#if element.maxOccurs != 1>
            for (${element.javaType} obj : _${element.name}) {
                xml.attribute(null, "${element.name}", obj.toString());
            }
        <#else>
            xml.startTag(null,  "${element.name}");
            xml.attribute(SOAPEnvelope.NS_XML_SCHEMA_INSTANCE,"type","xsd:${element.localPart}");
            xml.text(_${element.name}.toString());
            xml.endTag(null, "${element.name}");
        </#if>
        }
        </#list>
        </#if>
    }

    public void parse(SOAPBinding binding, Element el)
    {
        <#if atts??>
        //attributes
        <#list atts as att>
        ${att.name} = (${att.javaType}) parseAttribute(binding, el.getAttribute("${att.name}"), this, "${att.name}");
        </#list>
        </#if>

        <#if elements??>
        NodeList children = el.getChildNodes();
        for(int x = 0;x < children.getLength();x++)
        {
            Node childNde = children.item(x);
            if(childNde.getNodeType() != Node.ELEMENT_NODE)
            {
                continue;
            }
            Element childEl = (Element) childNde;
            <#list elements as element>
            <#if element.maxOccurs != 1>
            if(childEl.getLocalName().equals("${element.name}"))
            {
                ${element.javaType} _obj = (${element.javaType}) parseElement(binding, childEl, this, ${element.javaType}.class);
                _${element.name}.add(_obj); 
            }
            <#else>
            if(childEl.getLocalName().equals("${element.name}"))
            {
                _${element.name} = (${element.javaType}) parseElement(binding, childEl, this, ${element.javaType}.class); 
            }
            </#if>
            </#list>
        }
        </#if>
    }
}
