
(defvar *sample-graph-file*
  "/home/aakarsh/src/prv/common-lisp/clisp-sample/sample-graph.lisp")

(defvar *tg* "/home/aakarsh/src/prv/common-lisp/graphs/simple.txt")

(defun hash-keys (hash-table)
  (loop for key being
        the hash-keys of hash-table
        collect key))

(defun take(n ls)
  (loop for i from 0 to n
        for l  = ls then (cdr l)
        while (< i n)
        collect (car l)))

(defun split-by-char (str &optional (c #\Space))
  (when (and str (> (length str) 0))
    (loop for i = 0 then (1+ j)
          as j = (position c str :start i)
          collect (subseq str i j)
          while j)))

(defun str/split-by-one-space (str)
    "Returns a list of substrs of str divided by ONE space each.
Note: Two consecutive spaces will be seen as if there were an empty
str between them."
    (split-by-char str #\Space))


(defun str/join-words(words &optional (sep " "))
  (loop for word in words
        for result = word then (concatenate 'string result sep word)
       finally (return result)))

(defclass edge()
  ((start :initarg :start-node :accessor edge-start)
   (end :initarg :end-node :accessor edge-end )
   (flow :initarg :flow :initform 0)
   (capacity :initarg :capacity :initform 0 :accessor edge-capacity1)))

(defun make-edge (start end capacity)
  (make-instance 'edge :start-node start  :end-node end :capacity capacity))

(defun make-edge-string-list(ls)
  (make-edge (first ls ) (second ls) (parse-integer (third ls))))

(defclass node()
  ((name :initarg :name )
   (color :initarg :color :initform :white :accessor node-color)
   (neighbours :initarg :adj :initform '() :accessor node-neighbours)))

(defclass node-neighbour ()
  ((node :initarg :node)
   (capacity :initarg :capacity :initform 0)
   (flow :initarg :flow :initform 0)))

(defclass time-interval ()
  ((start  :initarg :start :initform 0 :accessor interval-start)
   (end  :initarg :end :initform 0  :accessor interval-end)))



(defun string->time-interval (str)
  (if (and  str (> (length str) 0) (not (string=  "tba" str)) )
      (let* ((str-pair (split-by-char str #\-))
             (start   (parse-integer (first str-pair)))
             (end     (parse-integer (second str-pair))))    
        (make-instance 'time-interval :start start :end end))))


(defclass graph()
  ((nodes :initarg :nodes :accessor graph-nodes)
   (edges :initarg :edges :accessor graph-edges)
   (flow :initarg :flow :accessor graph-flow)))

(defun string->name (name)
  (let* ((names (str/split-by-one-space name))
         (first-name "")
         (last-name "")
         (name nil))    
    (if (> (length names) 0)
        (setq name 
              (make-instance 'name
                             :first (first names)
                             :last (second names)))
      (setq name
            (make-instance 'name
                           :first ""
                           :last (first names))))
    name))




(defun ass/val (key ls)
  (let ((pair (assoc key ls)))
    (if pair
        (cadr pair) nil)))

(defun assoc->course (ls)
  (make-instance 'course-data
                 :course-name (ass/val :course-name ls)
                 :course-title (ass/val :course-title ls)
                 :course-section (ass/val :course-section ls)
                 :course-code (ass/val :course-code ls)
                 :course-type (ass/val :course-type ls)
                 :course-notes (ass/val :course-notes ls)
                 :course-capacity (ass/val :course-capacity ls)
                 :course-dates (ass/val :course-dates ls)
                 :course-days (ass/val :course-days ls)
                 :course-time (string->time-interval (ass/val :course-time ls))
                 :course-location (ass/val :course-location ls)
                 :course-professor (ass/val :course-professor ls)))

(defun professor-map->names(map)
  (hash-keys *professor-map*))

(defun professor-coures-map (courses)
  (loop for course in courses
        for prof = (course-professor course)
        with map = (make-hash-table :test 'equal)        
        for map-slot = (gethash prof map)
        while course
        finally (return map)
        do
        (if (not map-slot)
            (progn 
              (setf (gethash prof map) '())))        
        (push course (gethash prof map))))

(defun make-graph-simple (nodes edges)
  (make-instance 'graph 
                 :nodes nodes
                 :edges edges
                 :flow (make-flow (length nodes))))

(defun make-empty-node (name)
 (make-instance 'node :name name))

(defun make-flow (n)
  (make-array (list n n)))

(defun graph-find-edge(v1 v2 g)
  (dolist (edge (graph-edges g))
    (if (and (string=  (edge-start edge) (node-name v1))
             (string= (edge-end edge)  (node-name v2)))
        (return edge))))

(defun node-index->node (i g)
  (nth i (graph-nodes g)))

(defun node-name->index(name g)
  (position name (graph-nodes g) 
            :test #'string= :key #'node-name))

(defun node->index(node g)
  (node-name->index (node-name node) g))

(defun find-node(name nodes)
  (loop 
     for node in nodes 
     for k = nil do 
     (if (string= name (slot-value node 'name))
         (progn
           (return node)))))

(defun node-name(node)
  (if node
      (slot-value node 'name)))

(defun node-colorp(n c)
  (eql (node-color n) c))

(defun node-equals (n1 n2)
  (string= (node-name n1) (node-name n2) ))

(defun node-set-color (node color)
  (setf (slot-value node 'color) color))

(defun node-set-white (node)
  (node-set-color node :white))

(defun node-set-gray (node)
  (node-set-color node :gray))

(defun node-set-black (node)
  (node-set-color node :black))

(defun nodes-set-white (nodes)
  (mapcar #'node-set-white nodes))

(defun node-names(nodes)
  (loop 
    for node in nodes
    when node
    collect (node-name node)))

(defun node-count(g)
  (length (graph-nodes g)))

(defun node-not-terminal(node)
  (> (length (node-neighbours node)) 0))

(defun node-has-neighbourp(node neighbour)  
  (position (node-name neighbour) (node-neighbours node) :test #'string= :key #'node-name))

(defun node-add-neighbour(node neighbour)
  (if (not (node-has-neighbourp node neighbour))
        (push neighbour (slot-value node 'neighbours))))

(defun edge-capacity(v1 v2 g)
  (let ((edge (graph-find-edge v1 v2 g)))
    (if edge
        (edge-capacity1 edge))))

(defun edge-flow(v1 v2 g)
  (let ((flow (graph-flow g))
         (i1  (node->index v1 g))
         (i2  (node->index v2 g)))
    (aref flow i1 i2)))

(defun edge->flow(e g)
  (let ((flow (graph-flow g))
         (i1  (node-name->index (edge-start e) g))
         (i2  (node-name->index (edge-end e) g)))
    (aref flow i1 i2)))

(defun edge-flow-inc(v1 v2 inc g)
  (incf (aref (graph-flow g) 
              (node-name->index v1 g) 
              (node-name->index v2 g)) inc))

(defun graph-flow-setf(v1 v2 i g)
  (setf (aref (graph-flow g) 
              (node-name->index v1 g) 
              (node-name->index v2 g)) i))

(defun node-pair-flow-increment(v1 v2 inc g)
 (incf (aref (graph-flow g)
               (node->index v1 g)
               (node->index v2 g)) inc))

(defun edge-flow-increment(e inc g)
  (if nil
      (edge-print e g))
  (incf (aref (graph-flow g)
               (node-name->index(edge-start e) g)
               (node-name->index (edge-end e) g)) inc))

(defun edge->string(e g)
  (format nil "(~a)->(~a) [c:~a] [f:~a] <~a>" 
            (edge-start e) 
            (edge-end e) 
            (edge-capacity1 e)  
            (edge->flow e g)
            (edge-available-capacity e g)))

(defun edge-print(e g)
  (format t "~a~%"  (edge->string e g)))

(defun edge-available-capacity(e g)
  (- (edge-capacity1 e) (edge->flow e g)))

(defun edge-flow-to-capacity(v1 v2 g)
  (> (- (edge-capacity v1 v2  g ) (edge-flow v1 v2 g)) 0))

(defun edges->node-neighbours(n edges)
  (let ((adjv '()))
    (loop 
       for e in edges do
         (if (string= n (edge-start e ))
               (push (edge-end e) adjv)))
    (remove-duplicates adjv :test #'string=)))

(defun edges-funcall(g f)
  (loop for e in (graph-edges)
        do 
        (funcall f e)))

(defmacro bfs-enqueue!(n q)
  `(progn 
     (if ,n 
         (progn 
           (node-set-gray ,n)
           (push ,n ,q)))
     ,q))

(defmacro bfs-dequeue!(q)
  `(let ((n (pop ,q)))
     (if n
         (node-set-black n))
     n))

(defmacro push-node-and-predecessor!(node prev path)
  `(progn      
     (push  (list ,node ,prev) ,path)
     (if nil
         (format t "Pushed (~a ~a) -> [~a] ~%" 
                 (node-name ,node) 
                 (node-name ,prev)
                 (bfs-pred-path->string ,path)))
     ,path))


(defun reconstruct-path(pred_list start end)  
  (loop with path = '() 
        for prev = end then (cadr pair)
        for pair = (assoc (node-name prev) pred_list :key #'node-name :test #'string=)
        for cur =  (car pair)
        while cur
        with debug = nil
        finally (return path)        
        do
        (if debug (format t "cur:~a,prev:~a ~%" cur prev))
        (push cur path)))

(defun bfs-pred-path->string(path)
  (loop for elem in path
        for node = (car elem)
        for pred = (cadr elem)        
        for result = (str/join-words (list result           
                                           (format nil "(~a ~a)"  
                                                   (node-name node)  
                                                   (node-name pred))))
        finally (return result)))

(defun node-not-equals (n1 n2)
  (not (node-equals n1 n2)))

(defun bfs(start end graph)
  (let* ((nodes (graph-nodes graph))
        (start_node (find-node start nodes))
        (end_node   (find-node end nodes))
        (queue      '())
        (path        (list (list start_node nil))))
    (nodes-set-white nodes)    
    (bfs-enqueue! start_node queue)
    (loop for node in nodes
          with debug = nil
          for prev = nil then cur_node
          for cur_node = (bfs-dequeue! queue)
          while  (and cur_node (node-not-equals cur_node end_node)) 
          finally (if (node-not-equals cur_node end_node)
                      (progn 
                        (if debug
                            (format t "Returning on ~a Queue ~a " 
                                    (node-name cur_node ) queue))
                        nil)
                    (progn                    
                      (if prev 
                          (push-node-and-predecessor! cur_node prev path))                      
                      (return (reconstruct-path path start_node end_node))))
          do           
          (if debug (format t "~%cur_node[~a] bfs-queue[~a] ~%neighbours:~%~a ~%" 
                            (node-name cur_node) 
                            (node-names queue)
                            (mapcar #'(lambda(neighbour) 
                                        (format nil "[neighbour [~a] c:~a f:~a accessible:~a ]"  
                                                (node-name neighbour)
                                                (edge-capacity cur_node neighbour  graph)
                                                (edge-flow cur_node neighbour  graph)
                                                (edge-flow-to-capacity cur_node neighbour  graph)))
                                    (node-neighbours cur_node))))

          (loop for neighbour  in (node-neighbours cur_node)
                do 
                (if (and 
                     (node-colorp neighbour :white)
                     (edge-flow-to-capacity cur_node neighbour graph))
                    
                    (progn
                      (if debug (format t "~%Enqueue Neighbour: [~a] <c:~a> <f:~a> accessible:~a " 
                                        (node-name neighbour) 
                                        (edge-capacity cur_node neighbour graph) 
                                        (edge-flow cur_node neighbour graph)
                                        (edge-flow-to-capacity cur_node neighbour  graph)))                      
                      (bfs-enqueue! neighbour queue)
                      (if debug (format t "bfs-queue[~a] ~%" (node-names queue)))
                      (push-node-and-predecessor! neighbour cur_node  path)))))))


(defun path->string(path)
  (format nil "~{~A~^->~}" (node-names path)))

(defun path->on_vertex_pair(path g f)
  (loop for ls = path then (cdr ls)
        for (v1 v2) = (take 2 ls)
        while (and v1 v2)
        do
        (if (and v1 v2)
            (funcall f v1 v2))))

(defun path->edges(path g f)
  (loop for ls = path then (cdr ls)
        for (v1 v2) = (take 2 ls)
        for e = (graph-find-edge v1 v2 g)
        while (and v1 v2)
        do
        (if e
            (funcall f e))))

(defun path-flow-increment(path inc g )
  (path->edges path  g 
               #'(lambda(e) 
                   (if nil (format t "Before ~a ~%" (edge->string e g)))
                   (edge-flow-increment e inc g)
                   (if nil (format t "After  ~a ~%" (edge->string e g)))))  
  (path->on_vertex_pair (reverse path) g
             #'(lambda(v1 v2) 
                 (node-pair-flow-increment v1 v2 (- inc) g))))

(defvar *max-increment* 1000000000)

(defun find-path-increment(path g)
  (let* ((min *max-increment*)
         (cur-min min))
    (path->edges path g 
          #'(lambda(e)                     
              (setf cur-min (edge-available-capacity e g))
              (if (< cur-min min)
                  (setf min cur-min)))) 
    min))

(defun node-list-neighbours(node-name g)
  (node-names (node-neighbours (find-node node-name (graph-nodes g)))))

(defmacro make-node-if-none (node_name nodes)
  (let ((n (gensym "n"))) 
    `(let ((,n (find-node ,node_name ,nodes)))
       (if (not ,n)
           (progn
             (setq ,n (make-empty-node ,node_name))
             (push ,n ,nodes)))
       ,n)))


(defun add-nodes-from-edges(edges nodes)
  (loop for edge in edges 
        for cur_node = (make-node-if-none (edge-start edge) nodes)
        for end_node = (make-node-if-none (edge-end edge) nodes) 
        finally (return (sort nodes  #'string< :key #'node-name))
        do
        (node-add-neighbour cur_node end_node)))

(defun edges->nodes(edges)
  (let ((nodes '()))
    (add-nodes-from-edges edges nodes)))

(defun edges->node-names(edges)
  (let ((node-names '()))
    (dolist (e edges)
      (push (edge-start e) node-names)
      (push (edge-end e) node-names))
    (remove-duplicates node-names :test #'string= )))


(defun read-edge-file(file-name)
  (let ((in (open file-name :if-does-not-exist nil))
        (edges '()))
    (when in
      (loop for line = (read-line in nil)
         while line do 
           (let ((l (str/split-by-one-space line)))
             (when (eql (length l) 3)
               (push (make-edge-string-list l) edges)))))
    (close in)
    (nreverse edges)))

(defun read-course-data(file-name)
  (let ((in (open file-name :if-does-not-exist nil))
        (parsed-data '()))
    (when in
      (loop for term =  (read in nil)
            for course-data = '()
            while term
            do
            (loop for ls = term then (cddr ls)
                  for p1 = (car ls)
                  for p2 = (string-trim '(#\Space) (cadr ls))
                  for pair = (list p1 p2)
                  while (first pair)
                  do 
                  (push pair course-data))      
            (push (assoc->course course-data) parsed-data))      
            (close in))    
    parsed-data))

(defun parse-graph(file-name)
  (let* ((edges (read-edge-file file-name))
         (nodes (edges->nodes edges)))
    (make-graph-simple nodes edges)))

(defun make-edges-from-pairs (pair-list)
  (loop for (v1 v2) in pair-list
        collect (make-edge v1 v2 1)))

(defun pair-list->matching-graph (pairs &optional (source_name "Source") (sink_name "Sink"))
  (let* ((edges  (make-edges-from-pairs pairs))
         (nodes (edges->nodes edges))
         (new-edges '()))    
    (loop for edge in edges
          for l = (edge-start edge)
          for r = (edge-end edge)
          do 
          (push (make-edge  source_name l 1) new-edges)
          (push (make-edge  r sink_name 1) new-edges))
    (setq nodes (add-nodes-from-edges new-edges nodes))
    (make-graph-simple nodes (concatenate 'list edges new-edges))))

(defun print-edge(edge)
  (if edge 
      (if nil
          (format t "(~a)->(~a) [~a] ~%" 
                  (edge-start edge)
                  (edge-end edge)
                  (edge-capacity1 edge)))))

(defun print-graph-edges(g)
  (mapcar #'print-edge (graph-edges g)))

(defun max-flow(start end g)
  (loop for e in (graph-edges g)
        do 
        (graph-flow-setf (edge-start e) (edge-end e) 0 g))
   (loop for path = (bfs start end g)
         while path
         for increment =  (find-path-increment path g)
         for max_flow = increment then (+ max_flow increment)
         finally (return max_flow)
         do 
         (if nil (format t "Path ~a increment ~a ~%" (path->string path) increment))
         (path-flow-increment path increment g)))

(defun maximal-matching (pair-list)
  (let* ((matching-graph (pair-list->matching-graph pair-list))
        (match-size 0)
        (nodes (graph-nodes matching-graph))
        (num_nodes (length nodes))
        (matching '()))
    (setq match-size (max-flow "Source" "Sink" matching-graph))    
    (loop for n1 in nodes
          do 
          (loop for n2 in nodes
                 do
                 (if (and (not (string= "Source" (node-name n1)))
                          (not (string= "Sink" (node-name n2)))
                          (>  (edge-flow n1 n2 matching-graph) 0))                     
                     (push (list (node-name n1) (node-name n2))  matching))))
    matching))

(defclass name ()
((first-name :initarg :first :accessor first-name)
 (last-name  :initarg :last  :accessor last-name)))


(defclass course-data ()
  ((name :initarg :course-name 
         :accessor course-name)
   (title :initarg :course-title
          :accessor course-title)
   (section :initarg :course-section
            :accessor course-section)
   (code :initarg :course-code
         :accessor course-code)
   (type :initarg :course-type
         :accessor course-type)
   (time :initarg :course-time
         :accessor course-time)
   (notes :initarg :course-notes
          :accessor course-notes)
   (capacity :initarg :course-capacity
             :accessor course-capacity)
   (dates :initarg :course-dates
          :accessor course-dates)
   (days :initarg :course-days
          :accessor course-days)
   (location :initarg :course-location
             :accessor course-location)
   (professor :initarg :course-professor
              :accessor course-professor)))


(defun course-intersectp (course1 course2)
  (and 
   (time-interval-intersects (course-time course1) 
                             (course-time course2))
   (days-intersect  (course-days course1) 
                    (course-days course2))))

(defparameter *pt-faculty* 
           '("s ahmed" "s arabhi" "m bodas" "s desousa" "c fan"
             "t fish" "t huynh" "k jensen" "a jiru"
              "j jordan" "o kovaleva" "r low" "j lum"
              "w newball" "l papay" "l sega" "t smith" "a strong" 
              "a talebi" "p tanniru" "j trubey" "j wang"
              "e zabric" "m zoubeidi" "s vergara"   "varitanian"
              "m van der poel"   "a tran"   "rober"   "rigers"
              "v nguyen" "t nguyen"   "a nguyen"   "hillard")
           "List of part time faculty")

(defparameter *ft-faculty*
          '("j becker" "m blockus" "r dodd" "l foster"
            "t hsu" "k kellum" "r kubelka" "h ng"
            "s obaid" "b pence" "b peterson" "f rivera"
            "m saleem" "e schmeichel" "w so" "m stanley" 
            "c roddick" "sliva-spitzer" "shubin"  "pfifer"
            "katsura" "jackson" "beason" "alperin")
          "List of full time faculty")

(defparameter *ass-faculty*
           '( "s crunk" "a gottlieb" "p koev" "b lee"
              "j maruskin" "s simic"  "m cayco-gajic"  "bremer" )
           "List of Associate or Assistant Professors")

(defparameter *g* (parse-graph *tg*))
(defparameter es (graph-edges *g*))
(defparameter *courses* (read-course-data "data.lisp"))
(defparameter *professor-map* (professor-coures-map *courses*))


(defun betweenp (a i1 i2)
  (and (>= a i1)  (<= a i2)))

(defun interval-contains (a ti)
  (betweenp a (interval-start ti) (interval-end ti)))

(defun string->list (str)
  (concatenate 'list str))

(defun list-intersect(ls1 ls2)
  (loop for l in ls1
        do
        (if (member l ls2)
            (return t))))

(defun days-intersect(d1 d2)
  (list-intersect (string->list d1)
                  (string->list d2)))


(defun get-professor-courses (prof prof_map)
  (gethash prof prof_map))

(defun professor-overlapping-coursesp (prof1 prof2 map)
  (let ((prof1-courses  (get-professor-courses prof1 map))
        (prof2-courses  (get-professor-courses prof2 map )))
    (loop named outer for course1 in prof1-courses
          do
          (loop for course2 in prof2-courses
                do
                (if (course-intersectp course1 course2)
                    (return-from outer  t))))))


(defun time-interval-intersects (t1 t2)
  (if (or  (not t1) (not t2))
      nil      
    (or 
     (or    
      (interval-contains (interval-start t2) t1)
      (interval-contains (interval-end  t2) t1))
     (or    
      (interval-contains (interval-start t1) t2)
      (interval-contains (interval-end  t1) t2)))))


(defun professor-supervisable (prof1 prof2 map)
  (not (professor-overlapping-coursesp prof1 prof2 map)))

(defun professor-mapping (ls1 ls2 map)
  (loop for prof1 in ls1
        with mapping = '()
        finally (return mapping)
        do
        (loop for prof2 in ls2
              do
              (if (professor-supervisable prof1 prof2 map )
                  (push (list prof1 prof2) mapping)))))


(defun day-time-overlap(day1 time1 day2 time2 )
  (and  (days-intersect day1 day2) 
        (time-interval-intersects time1 time2)))

(defun test-max-flow()
  (eql 23 (max-flow "s" "t" *g*)))

(defun test-maximal-matching ()
  (eql 6 (length  (maximal-matching '(("A" "d") ("A" "h") ("A" "t")
                                      ("B" "g")  ("B" "p") ("B" "t")
                                      ("C" "a")   ("C" "g")   ("C" "h")  
                                      ("D" "h")   ("D" "p")   ("D" "t")  
                                      ("E" "a")   ("E" "c")   ("E" "d")  
                                      ("F" "c")   ("F" "d")   ("F" "p"))))))
(defun print-matching (matching)
  (loop for match in matching
        for  f = (first match)
        for  s = (second match)
        do
        (format t "~a -> ~a ~%" f s)))


(defun print-professor-groups(group1 group2 map)
  (let* ((avialable-matches
          (professor-mapping group1 group2  map))
         (matches (maximal-matching avialable-matches)))
    (print-matching matches)))

(defun print-final-mapping ()
  (format t "-------------------------------------- ~%")
  (format t "Full Time Mapping ~%")
  (format t "---------------------------------------- ~%")
  (print-professor-groups *ft-faculty* *pt-faculty* *professor-map*)
  (format t "---------------------------------------- ~%")
  (format t "Part Time Mapping ~%")
  (format t "---------------------------------------- ~%")
  (print-professor-groups *pt-faculty* *ass-faculty* *professor-map*))
