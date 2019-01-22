;;;; map-overlap.lisp

(in-package #:map-overlap)

(defconstant start-flag 1)
(defconstant end-flag 0)

(defun make-sorter (comparer &rest lambdas)
  (declare (optimize (speed 3))
	   (type function comparer)
	   (type (list function *) lambdas))
  (lambda (x y)
    (loop for fn in lambdas
       for xv = (funcall fn x)
       for yv = (funcall fn y)
       when (not (eq xv yv)) do (return (funcall comparer xv yv)))))

(defun map-overlap (spans get-start get-end get-result &key show-gaps) 
  "Call this to apply get-result to all unique intersections of spans.

Spans should be a list of items that get-start and get-end can apply to.
get-start and get-end should return a value that is orderable. 
get-result takes three arguments, the start and end of that intersection as returned by get-start and get-end, then the list of intersecting spans
make show-gaps truthy to call get-result for spans that the input spans do not intersect with."
  (declare (optimize (speed 3))
	   (type (function (t) number) get-start get-end)
	   (type (function (number number list)) get-result))
  
  (let* ((points-with-keys
	  (mapcan (lambda (s) (let ((n (cons s nil))) ;; Wrapping s in a list so that each hash is distinct
			     (list (list (funcall get-start s) start-flag n)
				   (list (funcall get-end s) end-flag n))))
		  spans))

	 (groups (groupby:groupby (lambda (a) (cons (car a) (cadr a)))
			    points-with-keys
			    :test #'equal))
	 (sorter (make-sorter #'< #'caar #'cdar))
	 (sorted-groups (sort groups sorter))
	 (stack (make-hash-table))
	 result)
    (declare (type list groups sorted-groups)
	     (type (function (number number) t) sorter))

    (loop for group in sorted-groups
       for first = nil then t
       for lastpos = (caar group) then pos
       for pos = (caar group)
       for is-start = (= (cdar group) start-flag)
       for nodes = (cadr group)
       do
	 (when (or (and show-gaps (< lastpos pos))
		   (and  (< 0 (hash-table-count stack)) first))
	   (push
	    (funcall get-result lastpos pos (loop for x being the hash-keys of stack
					       collect (car x)))
	    result))
	 (if is-start
	     (loop for node in nodes do (setf (gethash (caddr node) stack) 1))
	     (loop for node in nodes do (remhash (caddr node) stack))))
    (nreverse result)))
