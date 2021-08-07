<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:template match="/">
        <html>
            <head>
                <title>My iTunes Songs</title>
            </head>
            <style>
                    h1 {
                        text-align:center;
                        font-family:arial;
                        font-size:18pt;
                        color:#669966;
                    }
                    table {
                        border-style:none;
                        padding:0px;
                        margin:0px;
                        text-align:left;
                    }
                    th {
                        font-family:arial;
                        font-size:14pt;
                        background-color:#669966;
                        color:#FFFFFF;
                    }

                    td {
                        font-family:arial;
                        font-size:11pt;
                        color:#669966;
                    }
            </style>

            <body>
                <h1>My iTunes Songs</h1>
                <table style="width:100%">
                    <tr style="font-weight:bold">
                        <th style="width:20%">Name</th>
                        <th style="width:20%">Artist</th>
                        <th style="width:30%">Album</th>
                        <th style="width:30%">AM Link</th>
                    </tr>
                    <xsl:call-template name="main" />
                </table>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="main">
        <xsl:for-each select="/*/*/dict[1]/dict">
            <xsl:element name="tr">
                <xsl:call-template name="song" />
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="song">
        <tr>
            <xsl:if test="position() mod 2 != 1">
                <xsl:attribute name="style">background-color:#EEEEEE
                </xsl:attribute>
            </xsl:if>

            <td style="height=20px">
                <xsl:element name="a">
                    <xsl:attribute name="href">itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?songTerm=<xsl:value-of select="child::*[preceding-sibling::* = 'Name']" />&amp;artistTerm=<xsl:value-of select="child::*[preceding-sibling::* = 'Artist']" />&amp;albumTerm=<xsl:value-of select="child::*[preceding-sibling::* = 'Album']" />
                </xsl:attribute>
                <xsl:text></xsl:text>
                <xsl:value-of select="child::*[preceding-sibling::* = 'Name']" />
                </xsl:element>
            </td>

            <td>
                <xsl:element name="a">
                    <xsl:attribute name="href">itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?artistTerm=<xsl:value-of select="child::*[preceding-sibling::* = 'Artist']" />
                    </xsl:attribute>
                    <xsl:value-of select="child::*[preceding-sibling::* = 'Artist']" />
                </xsl:element>
            </td>

            <td>
                <xsl:element name="a">
                    <xsl:attribute name="href">itms://phobos.apple.com/WebObjects/MZSearch.woa/wa/advancedSearchResults?artistTerm=<xsl:value-of select="child::*[preceding-sibling::* = 'Artist']" />&amp;albumTerm=<xsl:value-of select="child::*[preceding-sibling::* = 'Album']" />
                    </xsl:attribute>
                <xsl:value-of select="child::*[preceding-sibling::* = 'Album']" />
                </xsl:element>
            </td>

            <td>
                <xsl:element name="a">
                    <xsl:attribute name="href">https://amp-api.music.apple.com/v1/catalog/de/search?l=de-de&amp;platform=web&amp;types=albums&amp;limit=1&amp;term=<xsl:value-of select="child::*[preceding-sibling::* = 'Artist']" />%20<xsl:value-of select="child::*[preceding-sibling::* = 'Album']" />
                    </xsl:attribute>
                <xsl:value-of select="child::*[preceding-sibling::* = 'Album']" />
                </xsl:element>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>