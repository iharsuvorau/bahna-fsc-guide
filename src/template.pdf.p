◊(require 
	racket/file 
	racket/system)

◊(define latex-source ◊string-append{
    \documentclass{tufte-handout}
    %\usepackage[cm-default,no-math]{fontspec} % загрузка и управление шрифтами
	% cm-default - не загружать шрифты Latin Modern
	% no-math - не вносить изменения в математические шрифты.
	\usepackage{xltxtra} % полезные переопределения для XeLaTeX, загрузка доп.пакетов
	\usepackage{polyglossia} % пакет для включения переносов (вместо babel)
	\setdefaultlanguage{russian} % выбор основного языка (для переносов)
	\setotherlanguage{english} % выбор дополнительного языка (для переносов)
	\defaultfontfeatures{Mapping=tex-text} % нужен для того чтобы работали стандартные сочетания символов ---, — << >> и т.п.
	\setmainfont{Linux Libertine O} % можно использовать любой OpenType шрифт, установленный в системе
	\setsansfont{Helvetica}
	\newfontfamily\russianfont{Linux Libertine O}
	%\setromanfont[Mapping=tex-text,Ligatures={Common, Rare, Discretionary},Numbers=OldStyle]{Linux Libertine O}
    %\setmonofont[Mapping=tex-text,Scale=MatchLowercase]{Fira Mono}

    % This is the default style configuration for Scribble-generated Latex
	\usepackage{verbatimbox} % for space before and after a table with \addvbuffer
	\usepackage{booktabs} % for table rullers
	\usepackage{multirow} % for multi rows in tables
	\usepackage{enumitem} % for itemize
	\usepackage{graphicx}
	\usepackage{ragged2e} % text alignment
	\usepackage{multicol} % multi columns
	\usepackage{hyperref}
	\renewcommand{\rmdefault}{ptm}
	\usepackage{relsize}
	\usepackage{mathabx}
	% Avoid conflicts between "mathabx" and "wasysym":
	\let\leftmoon\relax \let\rightmoon\relax \let\fullmoon\relax \let\newmoon\relax \let\diameter\relax
	\usepackage{wasysym}
	\usepackage{textcomp}
	\usepackage{framed}
	\usepackage[htt]{hyphenat}
	%\usepackage[usenames,dvipsnames]{color}
	%\hypersetup{bookmarks=true,bookmarksopen=true,bookmarksnumbered=true}

    \begin{document}
    ◊(apply string-append (cdr doc))
    \end{document}})

◊(define working-directory
    (make-temporary-file "pollen-latex-work-~a" 'directory))
◊(define temp-ltx-path (build-path working-directory "temp.ltx"))
◊(define command (format "xelatex -output-directory='~a' '~a'"
  working-directory temp-ltx-path))

◊(display-to-file latex-source temp-ltx-path #:exists 'replace)
◊(unless (system command) (error "xelatex: rendering error"))
◊(let ([pdf (file->bytes (build-path working-directory "temp.pdf"))])
   (delete-directory/files working-directory)
   pdf)