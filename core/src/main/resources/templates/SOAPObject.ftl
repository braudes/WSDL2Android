package ${package};

import org.xmlpull.v1.XmlSerializer;
import java.io.IOException;
import org.w3c.dom.Element;
import android.util.Log;
import java.lang.reflect.Field;

public class SOAPObject
{
    public void toXml(XmlSerializer xml, String name, String namespace) throws IOException
    {
        String ns = null;
        if(namespace != null && namespace.length() > 0)
        {
            ns = namespace;
        }
        else
        {
            ns = getNamespace();
        }

        xml.startTag(ns, name);
        addAttributesToNode(xml);
        addElementsToNode(xml);
        xml.endTag(ns, name);
    }

    public String getNamespace()
    {
        return null;
    }

    public void addAttributesToNode(XmlSerializer xml) throws IOException
    {

    }

    public void addElementsToNode(XmlSerializer xml) throws IOException
    {

    }

    public void parse(SOAPBinding binding, Element el)
    {

    }

    public static Object parseElement(SOAPBinding binding, Element el, Object parent, 
            String propName)
    {
        Object rtrn = null;

        if(parent == null)
        {
            return rtrn;
        }

        //Get the field on the parent object.
        Field field = null;
        try
        {
            field = parent.getClass().getDeclaredField(propName);
        }
        catch(Exception e)
        {
            if(binding.isLogEnabled())
            {
                Log.e(binding.getLogTag(), "Could not find field '" + propName
                        + "' on class '" + parent.getClass().getSimpleName() + "'.");
            }
            return rtrn;
        }

        try
        {
            rtrn = field.getType().newInstance();
        }
        catch(Exception e)
        {
            if(binding.isLogEnabled())
            {
                Log.e(binding.getLogTag(), "Could not create new instance of '"
                        + field.getType().getClass().getSimpleName() 
                        + "' for element field '" + propName + "' on class '" 
                        + parent.getClass().getSimpleName() + "'.");
            }
            return rtrn;
        }

        if(rtrn instanceof SOAPObject)
        {
            ((SOAPObject) rtrn).parse(binding, el);
        }
        else
        {
            rtrn = parsePrimitive(field.getDeclaringClass(), el.getTextContent());
        }
        
        return rtrn;
    }

    public static Object parseElement(SOAPBinding binding, Element el, Object parent, 
            Class clazz)
    {
        Object rtrn = null;

        if(parent == null)
        {
            return rtrn;
        }

        if(SOAPObject.class.isAssignableFrom(clazz))
        {
            try {
                rtrn = clazz.newInstance();
                ((SOAPObject) rtrn).parse(binding, el);
            } catch (Exception e) {
                Log.e(binding.getLogTag(), "Could not create new instance of '"
                        + clazz.getName() + "' on class '" 
                        + parent.getClass().getSimpleName() + "'.");
            }
        }
        else
        {
            rtrn = parsePrimitive(clazz, el.getTextContent());
        }
        
        return rtrn;
    }

    public Object parseAttribute(SOAPBinding binding, String attValue, 
            Object parent, String propName)
    {
        Object rtrn = null;

        if(parent == null)
        {
            return rtrn;
        }

        //Get the field on the parent object.
        Field field = null;
        try
        {
            field = parent.getClass().getDeclaredField(propName);
        }
        catch(Exception e)
        {
            if(binding.isLogEnabled())
            {
                Log.e(binding.getLogTag(), "Could not find field '" + propName
                        + "' on class '" + parent.getClass().getSimpleName() + "'.");
            }
            return rtrn;
        }

        try
        {
            rtrn = field.getType().newInstance();
        }
        catch(Exception e)
        {
            if(binding.isLogEnabled())
            {
                Log.e(binding.getLogTag(), "Could not create new instance of '"
                        + field.getType().getClass().getSimpleName() 
                        + "' for attribute field '" + propName + "' on class '" 
                        + parent.getClass().getSimpleName() + "'.");
            }
            return rtrn;
        }

        return parsePrimitive(field.getDeclaringClass(), attValue);
    }
    
    private static Object parsePrimitive(Class clazz, String value)
    {
        Object rtrn = null;

        if(String.class.isAssignableFrom(clazz))
        {
            rtrn = value;
        }
        else if(Double.class.isAssignableFrom(clazz))
        {
            rtrn = Double.valueOf(value);
        }
        else if(Integer.class.isAssignableFrom(clazz))
        {
            rtrn = Integer.valueOf(value);
        }
        else if(Long.class.isAssignableFrom(clazz))
        {
            rtrn = Long.valueOf(value);
        }
        else if(Short.class.isAssignableFrom(clazz))
        {
            rtrn = Short.valueOf(value);
        }
        else if(Float.class.isAssignableFrom(clazz))
        {
            rtrn = Float.valueOf(value);
        }
        //Byte, Calendar, Byte[], BigDecimal, QName, URI
        //...etc...
        
        return rtrn;
    }
}
