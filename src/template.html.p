◊(require txexpr)
<!DOCTYPE html>
<html lang="en">
    <head>
	<meta charset="utf-8"/>
	<title>◊(when (select 'h2 doc) (select 'h2 doc)) &mdash; Сохранить леса Беларуси: Практическое руководство</title>
	<link rel="stylesheet" href="/css/tufte.css"/>
	<link rel="stylesheet" href="/css/joel.css"/>
    </head>
    <body>
	◊(define prev-page (previous here))
	◊(define next-page (next here))
	<header class="site-header">
	    <nav>
		<a href="https://bahna.land/">bahna.land</a>
		<a href="/book.pdf" class="with-icon">
		    <img src="css/pdficon.png" height="15" width="15" style="width:auto" alt="Скачать PDF" />
		    <span>PDF-версия</span>
		</a>
	    </nav>
	    <nav>
		◊when/splice[prev-page]{
		<a href="◊|prev-page|">&larr; Назад</a>}
		<a href="/">&uarr; На главную</a>
		◊when/splice[next-page]{
		<a href="◊|next-page|">Вперёд &rarr;</a>}
	    </nav>
	</header>
	<article>
	    ◊(->html doc)
	</article>
	<footer>
	    ◊when/splice[prev-page]{
	    <div onclick="document.location.pathname='◊|next-page|';">
		<a href="◊|prev-page|">&larr; Назад</a>
		<span>◊(select-from-doc 'h1 (previous here))</span>
	    </div>}
	    <div onclick="document.location.pathname='/';">
		<a href="/">&uarr; На главную</a>
	    </div>
	    ◊when/splice[next-page]{
	    <div onclick="document.location.pathname='◊|next-page|';">
		<a href="◊|next-page|">Вперёд &rarr;<br></a>
		<span>◊(select-from-doc 'h1 (next here))</span>
	    </div>}
	</footer>
    </body>
</html>
