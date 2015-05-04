xquery version "1.0-ml";

import module namespace search =
	"http://marklogic.com/appservices/search" at
	"/MarkLogic/appservices/search/search.xqy";

declare option xdmp:output "method = html";



declare function local:findBook(
    $title as xs:string,
    $author as xs:string?,
    $year as xs:string?,
    $price as xs:string?,
    $category as xs:string?
) {
        let $query := 
        cts:and-query((
            (
            if ($category != "" and fn:exists($category)) then (
                cts:element-attribute-word-query(
                xs:QName("book"), xs:QName("category"), $category, "exact" ) )  else () ,
            if ($title != "" and fn:exists($title)) then (
                cts:element-word-query(
                xs:QName("title"), $title) ) else () ,
            if ($author != "" and fn:exists($author)) then (
                cts:element-word-query(
                xs:QName("author"), $author ) ) else () ,
            if ($year != "" and fn:exists($year)) then (
                cts:element-word-query(
                xs:QName("year"), $year ) ) else () ,
            if ($price != "") then (
                cts:element-word-query(
                xs:QName("price"), $price ) ) else ()
        )          
        ))
                

return
    <table border="1" id="myTable">
    <tr>
    <th><strong>Title</strong></th>
    <th><strong>Author</strong></th>
    <th><strong>Year</strong></th>
    <th><strong>Price</strong></th>
    <th><strong>Category</strong></th>
    </tr>
        {
            for $m in cts:search(//book, $query)
            order by $m/title
            return 
            <tr>
            <td>{data($m//title)}</td>
            <td>{data($m//author)}</td>
            <td>{data($m//year)}</td>
            <td>{data($m//price)}</td>
            <td>{data($m//@category)}</td>
            </tr>

        } 
    </table>
        
        };


declare function local:padString(
    $string as xs:string,
    $length as xs:integer,
    $padLeft as xs:boolean
) as xs:string {
    if (fn:string-length($string) = $length) then (
        $string
    ) else if (fn:string-length($string) < $length) then (
        if ($padLeft) then (
            local:padString(fn:concat("0", $string), $length, $padLeft)
        ) else (
            local:padString(fn:concat($string, "0"), $length, $padLeft)
        )
    ) else (
        fn:substring($string, 1, $length)
    )
};

declare function local:sanitizeInput($chars as xs:string?) {
    fn:replace($chars,"[\]\[<>{}\\();%\+]","")
};

declare variable $list :=
    if (xdmp:get-request-method() eq "GET") then (
        let $title as xs:string? := local:sanitizeInput(xdmp:get-request-field("title"))
        let $author as xs:string? := local:sanitizeInput(xdmp:get-request-field("author"))
        let $year as xs:string? := local:sanitizeInput(xdmp:get-request-field("year"))
        let $price as xs:string? := local:sanitizeInput(xdmp:get-request-field("price"))
        let $category as xs:string? := local:sanitizeInput(xdmp:get-request-field("category"))
        return
            local:findBook($title, $author, $year, $price, $category)
    ) else ();

(: build the html :)
xdmp:set-response-content-type("text/html"),
'<!DOCTYPE html>',
<html>
    <head>
        <title>Search Books</title>
        <link rel="stylesheet" type="text/css" href="styleSheet.css"/>
    </head>
    <body>
        <form name="search-book" action="search.xqy" method="get" style="margin:20px;">
            <fieldset>
                <legend>Search for a Book</legend>
                <label for="title">Title</label> <input type="text" id="title" name="title"/>
                <label for="author">Author</label> <input type="text" id="author" name="author"/>
                <label for="year">Year</label> <input type="text" id="year" name="year"/>
                <label for="price">Price</label> <input type="text" id="price" name="price"/>
                <label for="category">Category</label>
                <select name="category" id="category">
                    <option/>
                    {
                    for $c in ('CHILDREN','FICTION','NON-FICTION')
                    return
                        <option value="{$c}">{$c}</option>
                    }
                </select>
                <input type="submit" value="Search"/>
            </fieldset>
        </form>
        
        {
        if (fn:exists($list) and $list ne '') then (
            <h2 class="message">Results that match your search:<br/></h2> ,
            $list
        ) else 
            <div class="message">No Search Results.</div>
        }
    </body>
</html>