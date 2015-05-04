xdmp:set-response-content-type("text/html"),
'<!DOCTYPE html>',
<html>
    <head>
        <title>Booklist</title>
        <link rel="stylesheet" type="text/css" href="styleSheet.css"/>
    </head>
<body style="background-color:#5b91c7">

<h1 style="text-align:center;">Bookstore</h1>


{
for $x in doc()//book
order by $x/title
    return <div style="width:25%; float: left; background-color:lightgrey; border: 2px solid black; padding: 0 20px; margin: 25px;">
                <div>
                <h2 style="margin-bottom:0;">{data($x//title)} : <span style="font-size:16px">{data($x//author)}</span></h2>                
                <h5 style="margin-top:0; width: 100%">{data($x//@category)} - {data($x//year)} <span style="float:right;">Price: ${data($x//price)}</span></h5> 
                
            </div>
            </div>
}


</body>
</html>