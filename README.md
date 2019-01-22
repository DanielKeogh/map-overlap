# map-overlap
Utility for mapping over intersections of spans.

e.g.
```
(map-overlap:map-overlap 
	'((0 . 1) (2 . 4) (3 . 5)) 
	#'car 
	#'cdr 
	(lambda (a b c) (format nil "s:~a e:~a count:~a" a b (length c))))
```

Outputs:

```
("s:0 e:1 count:1" "s:2 e:3 count:1" "s:3 e:4 count:2" "s:4 e:5 count:1")
```
