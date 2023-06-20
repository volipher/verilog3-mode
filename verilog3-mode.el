;; -*- lexical-binding: t -*-

;; Verilog/SystemVerilog mode for Emacs.
;;
;; Font Lock is copied from the original Verilog-mode.
;; Some indentation functions were copied from SMIE.

(defvar verilog3-indent-offset 2
  "Indentation offset for Verilog3 mode.")

(defvar verilog3-relative-indent t
  "Speed up indentation by aligning to close-by statements.")

(defvar verilog3-cache-patterns t
  "Speed up indentation by caching regular expression patterns.")

(defvar verilog3-indent-begin-special nil
  "If true, indent begin differently. Don't indent a \"begin\" keyword that
  follows a one-statement keyword.")

;;; Font Lock

(let* ((verilog3-type-font-keywords
        (eval-when-compile
          (regexp-opt
           '("and" "buf" "bufif0" "bufif1" "cmos" "defparam" "event"
             "genvar" "highz0" "highz1" "inout" "input" "integer"
             "localparam" "mailbox" "nand" "nmos" "nor" "not" "notif0"
             "notif1" "or" "output" "parameter" "pmos" "pull0" "pull1"
             "pulldown" "pullup" "rcmos" "real" "realtime" "reg" "rnmos"
             "rpmos" "rtran" "rtranif0" "rtranif1" "semaphore" "signed"
             "specparam" "strong0" "strong1" "supply" "supply0" "supply1"
             "time" "tran" "tranif0" "tranif1" "tri" "tri0" "tri1" "triand"
             "trior" "trireg" "unsigned" "uwire" "vectored" "wand" "weak0"
             "weak1" "wire" "wor" "xnor" "xor"
             ;; 1800-2005
             "bit" "byte" "chandle" "const" "enum" "int" "logic" "longint"
             "packed" "ref" "shortint" "shortreal" "static" "string"
             "struct" "type" "typedef" "union" "var"
             ;; 1800-2009
             ;; 1800-2012
             "interconnect" "nettype" ) nil)))

       (verilog3-pragma-keywords
        (eval-when-compile
          (regexp-opt
           '("surefire" "0in" "auto" "leda" "rtl_synthesis" "synopsys"
             "verilint" ) nil)))

       (verilog3-ams-keywords
        (eval-when-compile
          (regexp-opt
           '("above" "abs" "absdelay" "abstol" "ac_stim" "access" "acos"
             "acosh" "aliasparam" "analog" "analysis" "asin" "asinh" "atan"
             "atan2" "atanh" "branch" "ceil" "connect" "connectmodule"
             "connectrules" "continuous" "cos" "cosh" "ddt" "ddt_nature"
             "ddx" "discipline" "discrete" "domain" "driver_update"
             "endconnectmodule" "endconnectrules" "enddiscipline" "endnature" "endparamset"
             "exclude" "exp" "final_step" "flicker_noise" "floor" "flow"
             "from" "ground" "hypot" "idt" "idt_nature" "idtmod" "inf"
             "initial_step" "laplace_nd" "laplace_np" "laplace_zd"
             "laplace_zp" "last_crossing" "limexp" "ln" "log" "max"
             "merged" "min" "nature" "net_resolution" "noise_table"
             "paramset" "potential" "pow" "resolveto" "sin" "sinh" "slew"
             "split" "sqrt" "tan" "tanh" "timer" "transition" "units"
             "white_noise" "wreal" "zi_nd" "zi_np" "zi_zd" "zi_zp"
             ;; Excluded AMS keywords: "assert" "cross" "string"
             ) nil)))

       (verilog3-font-general-keywords
        (eval-when-compile
          (regexp-opt
           '("always" "assign" "automatic" "case" "casex" "casez" "cell"
             "config" "deassign" "default" "design" "disable" "edge" "else"
             "endcase" "endconfig" "endfunction" "endgenerate" "endmodule"
             "endprimitive" "endspecify" "endtable" "endtask" "for" "force"
             "forever" "fork" "function" "generate" "if" "ifnone" "incdir"
             "include" "initial" "instance" "join" "large" "liblist"
             "library" "macromodule" "medium" "module" "negedge"
             "noshowcancelled" "posedge" "primitive" "pulsestyle_ondetect"
             "pulsestyle_onevent" "release" "repeat" "scalared"
             "showcancelled" "small" "specify" "strength" "table" "task"
             "use" "wait" "while"
             ;; 1800-2005
             "alias" "always_comb" "always_ff" "always_latch" "assert"
             "assume" "before" "bind" "bins" "binsof" "break" "class"
             "clocking" "constraint" "context" "continue" "cover"
             "covergroup" "coverpoint" "cross" "dist" "do" "endclass"
             "endclocking" "endgroup" "endinterface" "endpackage"
             "endprogram" "endproperty" "endsequence" "expect" "export"
             "extends" "extern" "final" "first_match" "foreach" "forkjoin"
             "iff" "ignore_bins" "illegal_bins" "import" "inside"
             "interface" "intersect" "join_any" "join_none" "local"
             "matches" "modport" "new" "null" "package" "priority"
             "program" "property" "protected" "pure" "rand" "randc"
             "randcase" "randsequence" "return" "sequence" "solve" "super"
             "tagged" "this" "throughout" "timeprecision" "timeunit"
             "unique" "virtual" "void" "wait_order" "wildcard" "with"
             "within"
             ;; 1800-2009
             "accept_on" "checker" "endchecker" "eventually" "global"
             "implies" "let" "nexttime" "reject_on" "restrict" "s_always"
             "s_eventually" "s_nexttime" "s_until" "s_until_with" "strong"
             "sync_accept_on" "sync_reject_on" "unique0" "until"
             "until_with" "untyped" "weak"
             ;; 1800-2012
             "implements" "soft" ) nil)))

       (verilog3-font-grouping-keywords
        (eval-when-compile
          (regexp-opt
           '( "begin" "end" ) nil))))

  ;;https://www.gnu.org/software/emacs/manual/html_node/elisp/Search_002dbased-Fontification.html
  (setq verilog3-font-lock-keywords
        (list
         ;; Fontify all builtin keywords
         (concat "\\<\\(" verilog3-font-general-keywords "\\|"
                 ;; And user/system tasks and functions
                 "\\$[a-zA-Z][a-zA-Z0-9_\\$]*"
                 "\\)\\>")
         ;; Fontify all types
         (cons (concat "\\<\\(" verilog3-font-grouping-keywords "\\)\\>")
               'font-lock-type-face)
         (cons (concat "\\<\\(" verilog3-type-font-keywords "\\)\\>")
               'font-lock-type-face)
         ;; Fontify Verilog-AMS keywords
         (cons (concat "\\<\\(" verilog3-ams-keywords "\\)\\>")
               'font-lock-type-face)))

  (setq verilog3-font-lock-keywords-1
        (append verilog3-font-lock-keywords
                (list
                 ;; Fontify module definitions
                 (list
                  "\\<\\(\\(macro\\|connect\\)?module\\|primitive\\|class\\|program\\|interface\\|package\\|task\\)\\>\\s-*\\(\\sw+\\)"
                  '(1 font-lock-keyword-face)
                  '(3 font-lock-function-name-face prepend))
                 ;; Fontify function definitions
                 (list
                  (concat "\\<function\\>\\s-+\\(integer\\|real\\(time\\)?\\|time\\)\\s-+\\(\\sw+\\)" )
                  '(1 font-lock-keyword-face)
                  '(3 font-lock-constant-face prepend))
                 '("\\<function\\>\\s-+\\(\\[[^]]+\\]\\)\\s-+\\(\\sw+\\)"
                   (1 font-lock-keyword-face)
                   (2 font-lock-constant-face append))
                 '("\\<function\\>\\s-+\\(\\sw+\\)"
                   1 'font-lock-constant-face append))))

  (setq verilog3-font-lock-keywords-2
        (append verilog3-font-lock-keywords-1
                (list
                 ;; Fontify pragmas
                 (concat "\\(//\\s-*\\(" verilog3-pragma-keywords "\\)\\s-.*\\)")
                 ;; Fontify escaped names
                 '("\\(\\\\\\S-*\\s-\\)"  0 font-lock-function-name-face)
                 ;; Fontify macro definitions/ uses
                 '("`\\s-*[A-Za-z][A-Za-z0-9_]*" 0 (if (boundp 'font-lock-preprocessor-face)
                                                       'font-lock-preprocessor-face
                                                     'font-lock-type-face))
                 ;; Fontify delays/numbers
                 '("\\(@\\)\\|\\([ \t\n\f\r]#\\s-*\\(\\([0-9_.]+\\('s?[hdxbo][0-9a-fA-F_xz]*\\)?\\)\\|\\(([^()]+)\\|\\sw+\\)\\)\\)"
                   0 font-lock-type-face append)
                 ;; Fontify property/sequence cycle delays - these start with '##'
                 '("\\(##\\(\\sw+\\|\\[[^]]+\\]\\)\\)"
                   0 font-lock-type-face append)
                 ;; Fontify instantiation names
                 '("\\([A-Za-z][A-Za-z0-9_]*\\)\\s-*(" 1 font-lock-function-name-face))))

  (setq verilog3-font-lock-keywords-3
        verilog3-font-lock-keywords-2))

;;; Syntax Table

(defvar verilog3-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; Populate the syntax TABLE.
    (modify-syntax-entry ?\\ "\\" table)
    (modify-syntax-entry ?+ "." table)
    (modify-syntax-entry ?- "." table)
    (modify-syntax-entry ?= "." table)
    (modify-syntax-entry ?% "." table)
    (modify-syntax-entry ?< "." table)
    (modify-syntax-entry ?> "." table)
    (modify-syntax-entry ?& "." table)
    (modify-syntax-entry ?| "." table)
    (modify-syntax-entry ?` "w" table) ; ` is part of definition symbols in Verilog
    (modify-syntax-entry ?_ "w" table)
    (modify-syntax-entry ?\' "." table)

    ;; Set up TABLE to handle block and line style comments.
    (modify-syntax-entry ?/  ". 124b" table)
    (modify-syntax-entry ?*  ". 23"   table)
    (modify-syntax-entry ?\n "> b"    table)
    table)
  "Syntax table used in SysVerilog mode buffers.")

;;; Indentation

(defvar verilog3-indent-matching-keywords
  '(
    ;; B
    ("begin" . "end")
    ;; C
    ("case" . "endcase")
    ("casex" . "endcase")
    ("casez" . "endcase")
    ("class" . "endclass")
    ("clocking" . "endclocking")
    ("covergroup" . "endgroup")
    ("config" . "endconfig")
    ("connectmodule" . "endconnectmodule")
    ;; F
    ("fork" . "join")
    ("fork" . "join_any")
    ("fork" . "join_none")
    ("function" . "endfunction")
    ;; G
    ("generate" . "endgenerate")
    ;; I
    ("interface" . "endinterface")
    ;; M
    ("module" . "endmodule")
    ("macromodule" . "endmodule")
    ;; P
    ("program" . "endprogram")
    ("package" . "endpackage")
    ("primitive" . "endprimitive")
    ("property" . "endproperty")
    ;; R
    ("randcase" . "endcase")
    ;; S
    ("specify" . "endspecify")
    ("sequence" . "endsequence")
    ("randsequence" . "endsequence")
    ;; T
    ("task" . "endtask")
    ("table" . "endtable")
    ;; UVM
    ("`uvm_component_utils_begin" . "`uvm_component_utils_end")
    ("`uvm_component_param_utils_begin" . "`uvm_component_utils_end")
    ("`uvm_field_utils_begin" . "`uvm_field_utils_end")
    ("`uvm_object_utils_begin" . "`uvm_object_utils_end")
    ("`uvm_object_param_utils_begin" . "`uvm_object_utils_end")
    ("`uvm_sequence_utils_begin" . "`uvm_sequence_utils_end")
    ("`uvm_sequencer_utils_begin" . "`uvm_sequencer_utils_end")
    )
  "All matching keywords for indentation.")

(defvar verilog3-indent-one-line-keywords
  '("if"
    "else"
    "for"
    "while"
    "initial"
    "final"
    "repeat"
    "always"
    "always_latch"
    "always_ff"
    "always_comb")
  "Keywords that require indentation only for one statement.")

(defvar verilog3-left-aligned-keywords
  '("`begin_keywords"
    "`celldefine"
    "`default_nettype"
    ;;"`define"
    "`else"
    "`elsif"
    "`end_keywords"
    "`endcelldefine"
    "`endif"
    "`ifdef"
    "`ifndef"
    ;;"`include"
    ;;"`line"
    ;;"`nounconnected_drive"
    ;;"`pragma"
    ;;"`resetall"
    ;;"`timescale"
    ;;"`unconnected_drive"
    ;;"`undef"
    ;;"`undefineall"
    )
  "Keywords (directives) that should be left aligned.")

(defvar verilog3-indent-equivalent-cache nil)
(defvar verilog3-indent-matching-cache nil)
(defvar verilog3-token-regex nil
  "A search for this expression is used as an approximation to regular
backward/forward token functions.")

(defun verilog3-indent-buffer-measure-time ()
  "Indent buffer and measure time taken to do so."
  (let ((time (current-time)))
    (indent-region (point-min) (point-max))
    (message "%.06f" (float-time (time-since time)))))

(defun verilog3-paired-keyword-p (type kw)
  "Return non-nil if keyword KW of TYPE is part of a keyword pair. TYPE may be
:begin or :end"
  (let ((begin-keywords (mapcar #'car verilog3-indent-matching-keywords))
        (end-keywords (mapcar #'cdr verilog3-indent-matching-keywords)))
    (if (eq type :begin)
        (member kw begin-keywords)
      (member kw end-keywords))))

(defun verilog3-equivalent-regexp-1 (type kw)
  "Return the same thing as `verilog3-equivalent-regexp' but cache the value
for future calls."
  (when (verilog3-paired-keyword-p type kw)
    (if verilog3-cache-patterns
        (let* ((type-alist (cdr (assoc type verilog3-indent-equivalent-cache)))
               (cached (cdr (assoc kw type-alist))))
          (if (not cached)
              (let ((begin-alist
                     (cdr (assoc :begin verilog3-indent-equivalent-cache)))
                    (end-alist
                     (cdr (assoc :end verilog3-indent-equivalent-cache))))
                (setq cached (verilog3-equivalent-regexp type kw))
                (if (eq type :begin)
                    (setq begin-alist (append `((,kw . ,cached)) begin-alist))
                  (setq end-alist (append `((,kw . ,cached)) end-alist)))
                (setq verilog3-indent-equivalent-cache
                      (list
                       (cons :begin begin-alist)
                       (cons :end end-alist)))))
          cached)
      (verilog3-equivalent-regexp type kw))))

(defun verilog3-matching-regexp-1 (type kw)
  "Return the same thing as `verilog3-matching-regexp' but cache the value
for future calls."
  (when (verilog3-paired-keyword-p type kw)
    (if verilog3-cache-patterns
        (let* ((type-alist (cdr (assoc type verilog3-indent-matching-cache)))
               (cached (cdr (assoc kw type-alist))))
          (if (not cached)
              (let ((begin-alist
                     (cdr (assoc :begin verilog3-indent-matching-cache)))
                    (end-alist
                     (cdr (assoc :end verilog3-indent-matching-cache))))
                (setq cached (verilog3-matching-regexp type kw))
                (if (eq type :begin)
                    (setq begin-alist (append `((,kw . ,cached)) begin-alist))
                  (setq end-alist (append `((,kw . ,cached)) end-alist)))
                (setq verilog3-indent-matching-cache
                      (list
                       (cons :begin begin-alist)
                       (cons :end end-alist)))))
          cached)
      (verilog3-matching-regexp type kw))))

(defun verilog3-equivalent-regexp (type kw)
  "Returns a regexp to match keywords equivalent to keyword KW of TYPE. TYPE
may be :begin or :end"
  (let (matchlist eqlist)
    ;; Populate "matchlist". This is a list of all keywords that match KW.
    (dolist (pair verilog3-indent-matching-keywords)
      (when (equal kw (if (eq type :end) (cdr pair) (car pair)))
        (let ((match (if (eq type :end) (car pair) (cdr pair))))
          (setq matchlist (append (list match) matchlist)))))
    ;; For each match, search for it's matching keyword.
    (dolist (match matchlist)
      (dolist (pair verilog3-indent-matching-keywords)
        (when (equal match (if (eq type :end) (car pair) (cdr pair)))
          (let ((match2 (if (eq type :end) (cdr pair) (car pair))))
            (setq eqlist (append (list match2) eqlist))))))
    (verilog3-keyword-regexp eqlist)))

(defun verilog3-matching-regexp (type kw)
  "Returns a regexp to match keywords that partner with keyword KW of
TYPE. TYPE may be :begin or :end."
  (let (matchlist)
    (dolist (pair verilog3-indent-matching-keywords)
      (when (equal kw (if (eq type :end) (cdr pair) (car pair)))
        (let ((match (if (eq type :end) (car pair) (cdr pair))))
          (setq matchlist (append (list match) matchlist)))))
    (verilog3-keyword-regexp matchlist)))

(defun verilog3-keyword-regexp (keywords)
  "For a list of keywords, return a regexp that will match any of them."
  (let (pat)
    (dolist (kw keywords)
      (if pat
            (setq pat (concat pat "\\|\\<" kw))
        (setq pat (concat "\\<" kw)))
      (when pat
        (setq pat (concat pat "\\>"))))
    pat))

(defun verilog3-set-token-regex ()
  "Regex matching keywords, semicolons or parens. Parentheses are matched in
group number 1."
  (unless verilog3-token-regex
    (let* ((begin-keywords (mapcar #'car verilog3-indent-matching-keywords))
           (end-keywords (mapcar #'cdr verilog3-indent-matching-keywords))
           (kw-regex (verilog3-keyword-regexp
                      (append begin-keywords end-keywords
                              verilog3-indent-one-line-keywords))))
      (setq verilog3-token-regex (concat kw-regex "\\|;\\|\\([][(){}]\\)")))))
  
(defun verilog3-backward-token-1 ()
  "Skip to keywords or parens - the only tokens we usually care about. Search
for the previous instance of `verilog3-token-regex' and set point to the
beginning of the occurrence. If the match is a paren-type character, point is
set to just after that match and an empty string is returned. This function
skips any matches inside comments."
  (verilog3-set-token-regex)
  (let ((done nil))
    (while (and (not done)
                (let ((case-fold-search nil))
                  (re-search-backward verilog3-token-regex nil t)))
      (unless (verilog3-comment-or-string-p) (setq done t)))
    (when done
      (if (not (match-end 1))
          (match-string-no-properties 0)
        (forward-char 1)
        ""))))

(defun verilog3-forward-token-1 ()
  "Skip to keywords or parens - the only tokens we usually care about. Search
for the next instance of `verilog3-token-regex' and set point to the
end of the occurrence. If the match is a paren-type character, point is set to
just before that match and an empty string is returned. This function skips
any matches inside comments."
  (verilog3-set-token-regex)
  (let ((done nil))
    (while (and (not done)
                (let ((case-fold-search nil))
                  (re-search-forward verilog3-token-regex nil t)))
      (unless (verilog3-comment-or-string-p) (setq done t)))
    (when done
      (if (not (match-end 1))
          (match-string-no-properties 0)
        (backward-char 1)
        ""))))

(defun verilog3-backward-token ()
  "Copied from SMIE."
  (forward-comment (- (point)))
  (buffer-substring-no-properties
   (point)
   (progn (if (zerop (skip-syntax-backward "."))
              (skip-syntax-backward "w_'"))
          (point))))

(defun verilog3-forward-token ()
  "Copied from SMIE."
  (forward-comment (point-max))
  (buffer-substring-no-properties
   (point)
   (progn (if (zerop (skip-syntax-forward "."))
              (skip-syntax-forward "w_'"))
          (point))))

(defun verilog3-comment-or-string-p ()
  "Return non-nil if point is inside a comment or string."
    (or (nth 3 (syntax-ppss))
        (nth 4 (syntax-ppss))))

(defun verilog3-indent-bolp ()
  "Return non-nil if the current token is the first on the line."
  (save-excursion (skip-chars-backward " \t") (bolp)))

(defun verilog3-backward-sexp (token)
  "Skip to the matching keyword of TOKEN. If TOKEN is empty or nil, try
backward-sexp. If a matching token wasn't found, do not move point."
  (if (zerop (length token))
      (condition-case nil
          (backward-sexp 1)
        (scan-error nil))
    (let* ((matching-kw (verilog3-matching-regexp-1 :end token))
           (equivalent-kw (verilog3-equivalent-regexp-1 :end token)))
      (when matching-kw
        (unless equivalent-kw (error "Did not find equivalent keywords"))
        (let ((sp (point))
              (pat (concat matching-kw "\\|\\(" equivalent-kw "\\)"))
              (open-count 1))
          ;; Keep going until we found our matching keyword or until there are
          ;; no more matches.
          (while (and (> open-count 0)
                      (let ((case-fold-search nil))
                        (re-search-backward pat nil t)))
            ;; Only consider this match if it's not a string or comment or 
            ;; a special begin keyword.
            (unless (or (verilog3-comment-or-string-p)
                        (verilog3-special-open-keyword-p
                         (match-string-no-properties 0)))
              (setq open-count
                    (if (match-end 1) (1+ open-count) (1- open-count)))))
          ;; If our search didn't succeed, go back to the original position.
          (when (> open-count 0) (goto-char sp)))))))

(defun verilog3-forward-sexp (token)
  "Skip to the matching keyword of TOKEN. If TOKEN is empty or nil, try
forward-sexp. If a matching token wasn't found, do not move point."
  (if (zerop (length token))
      (condition-case nil
          (forward-sexp 1)
        (scan-error nil))
    (let* ((matching-kw (verilog3-matching-regexp-1 :begin token))
           (equivalent-kw (verilog3-equivalent-regexp-1 :begin token)))
      (when matching-kw
        (unless equivalent-kw (error "Did not find equivalent keywords"))
        (let ((sp (point))
              (pat (concat matching-kw "\\|\\(" equivalent-kw "\\)"))
              (open-count 1))
          ;; Keep going until we found our matching keyword or until there are
          ;; no more matches.
          (while (and (> open-count 0)
                      (let ((case-fold-search nil))
                        (re-search-forward pat nil t)))
            ;; Only consider this match if it's not a string or comment or 
            ;; a special begin keyword.
            (unless (or (verilog3-comment-or-string-p)
                        (verilog3-special-open-keyword-p
                         (match-string-no-properties 0)))
              (setq open-count
                    (if (match-end 1) (1+ open-count) (1- open-count)))))
          ;; If our search didn't succeed, go back to the original position.
          (when (> open-count 0) (goto-char sp)))))))

(defun verilog3-backward-stride (&optional stop-token)
  "Move backward to the last pivot token or STOP-TOKEN, whichever comes
first. Return nil if something unexpected happens. A pivot token is a token
that is sufficient to determine indentation.

This function only examines tokens matching `verilog3-token-regex'.

If `verilog3-relative-indent' is non-nil, this function can return an empty
string to suggest that the next regular line can be indented the same as the
current point."
  (let* ((begin-keywords (mapcar #'car verilog3-indent-matching-keywords))
         (end-keywords (mapcar #'cdr verilog3-indent-matching-keywords))
         (rel-true-keywords (append '(";") begin-keywords))
         ;; `else' is the only keyword that "breaks" the rule that two
         ;; consecutive begin keywords or semicolons means two separate
         ;; statements.
         ;; Note that if we see two nested begin keywords, the second will be
         ;; an unbalanced token anyway. We return without trying relative
         ;; indentation.
         (rel-all-keywords (append rel-true-keywords '("else")))
         rel0 rel1
         token
         end-of-statement)
    (condition-case nil
        (catch 'return
          (while t
            (let ((sp (point)))
              (setq token (verilog3-backward-token-1))
              (when (and stop-token (equal token stop-token))
                (throw 'return token))
              ;; Unbalanced open token
              (when (member token begin-keywords) (throw 'return token))
              (when (save-excursion (backward-char 1) (looking-at "\\s("))
                (throw 'return "("))
              ;; If we see a semicolon or an `end' keyword, all one-statement
              ;; indentation is considered to have ended. The constraint block
              ;; allows `if' statements to terminate with "}". Let's use that as
              ;; an end token too.
              (when (not end-of-statement)
                (when (or (equal (string (char-before)) "}")
                          (member token (append '(";") end-keywords)))
                  (setq end-of-statement t)))
              (verilog3-backward-sexp token)
              ;; Unbalanced close token
              (when (member (save-excursion (verilog3-forward-token))
                            end-keywords)
                (throw 'return token))
              ;; If we haven't moved...
              (when (or (>= (point) sp) (null token)) (throw 'return nil)))
            ;; If we meet a one-statement keyword without meeting a full statement
            ;; before, return.
            (when (and (member token verilog3-indent-one-line-keywords)
                       (not end-of-statement))
              (throw 'return token))
            ;; Relative Indentation:
            ;; Keep the past two `rel-all-keywords'. When both of them are
            ;; `rel-true-keywords', we found a legitimate end of statement.
            (when verilog3-relative-indent
              (let ((savep (point))
                    (token (verilog3-forward-token)))
                (when (member token rel-all-keywords)
                  (setq rel0 rel1)
                  (setq rel1 (if (member token rel-true-keywords) (point)))
                  (when (and (numberp rel0) (numberp rel1))
                    (unless (equal token ";")
                      (verilog3-forward-sexp token))
                    (forward-comment (point-max))
                    ;; This point is good for indentation if it is at the
                    ;; beginning of the line and it isn't indented specially.
                    (when (and (verilog3-indent-bolp)
                               (not (member (save-excursion (verilog3-forward-token))
                                            verilog3-left-aligned-keywords)))
                      (throw 'return ""))))
                (goto-char savep)))))
      (error nil))))

(defun verilog3-forward-comment-same-line ()
  "Skip comments but stay on same line."
  (let ((sp (point))
        (mp (line-end-position)))
    (forward-comment (point-max))
    (when (> (point) mp) (goto-char sp))))

(defun verilog3-special-open-keyword-p (tok)
  "Return t if the opening keyword TOK means something else. POINT should be
just before TOK.
Example: While `fork' generally starts a new block, it means something else
when preceeded by `wait'."
  (cond
   ;; "assert property", etc.
   ((save-excursion
      (and (member tok '("property"))
           (member (verilog3-backward-token) '("assert"
                                               "assume"
                                               "cover"
                                               "restrict"))))
    t)
   ;; "wait fork", etc.
   ((save-excursion
      (and (member tok '("fork"))
           (member (verilog3-backward-token) '("wait"
                                               "disable"))))
    t)
   ;; "virtual interface"
   ((save-excursion
      (and (member tok '("interface"))
           (member (verilog3-backward-token) '("virtual"))))
    t)
   ;; "default clocking" without "@" (event) is a single statement.
   ((and (member tok '("clocking"))
         (not
          (save-excursion
            (beginning-of-line)
            (re-search-forward "clocking.*@" (line-end-position) t 1))))
    t)
   ;; "extern", etc.
   ((and (member tok '("function" "task" "module"))
         (save-excursion
           (beginning-of-line)
           (re-search-forward
            (concat "\\("
                    (verilog3-keyword-regexp '("extern"
                                               "import"
                                               "export"
                                               "pure virtual"
                                               ))
                    "\\)" ".*\\<" tok "\\>")
            (line-end-position) t 1)))
    t)))

(defun verilog3-indent-comment-rule ()
  (when (verilog3-comment-or-string-p)
    (current-indentation)))

(defun verilog3-indent-close-paren-rule ()
  "Calculate indent when we're looking at a close paren."
    (save-excursion
      (verilog3-forward-comment-same-line)
      (when (looking-at "\\s)")
        (forward-char 1)
        (verilog3-backward-sexp "")
        (forward-char 1)
        (let ((save-col (current-column))
              (save-eol (line-end-position))
              (save-pt (point)))
          (verilog3-forward-token)
          ;; Check whether there is content after the open parenthesis on the
          ;; same line.
          (if (<= (point) save-eol)
              save-col
            (goto-char save-pt)
            (current-indentation))))))

(defun verilog3-indent-inside-paren-rule (pivot-token pivot-point)
  "Calculate indent when PIVOT-POINT is an open paren and there is content on
the same line."
  (when (equal pivot-token "(")
    (save-excursion
      (goto-char pivot-point)
      (let ((save-col (current-column))
            (save-eol (line-end-position)))
        (verilog3-forward-token)
        (if (> (point) save-eol)
            nil
          save-col)))))

(defun verilog3-indent-begin-special-rule (pivot-token pivot-point)
  "Calculate indent for the \"begin\" keyword when PIVOT-TOKEN is a one-statement
keyword."
  (when (and verilog3-indent-begin-special
             (save-excursion
               (verilog3-forward-comment-same-line)
               (looking-at (verilog3-keyword-regexp '("begin"))))
             pivot-token
             (string-match (verilog3-keyword-regexp
                            verilog3-indent-one-line-keywords)
                           pivot-token))
    (save-excursion
      (goto-char pivot-point)
      (current-indentation))))

(defun verilog3-indent-else-rule (pivot-token pivot-point)
  "Calculate indent when looking at an else token."
  (save-excursion
    (verilog3-forward-comment-same-line)
    (when (and (looking-at "\\<else\\>")
               (equal (verilog3-backward-stride "if") "if"))
      (current-indentation))))

(defun verilog3-indent-left-aligned-keyword-rule (pivot-token pivot-point)
  "Calculate indent when looking at left aligned keywords."
  (save-excursion
    (verilog3-forward-comment-same-line)
    (when (looking-at
           (verilog3-keyword-regexp verilog3-left-aligned-keywords))
      0)))

(defun verilog3-indent-special-open-keyword-rule (pivot-token pivot-point)
  "Calculate indent when PIVOT-TOKEN is a special begin keyword."
  (save-excursion
    (let ((savep (point))
          (fallback-indent (progn
                             (goto-char pivot-point)
                             (current-indentation))))
      (when (verilog3-special-open-keyword-p pivot-token)
        (or (verilog3-indent-calculate savep)
            fallback-indent)))))

(defun verilog3-indent-close-keyword-rule ()
  "Calculate indentation when looking at a close keyword."
  (save-excursion
    (let ((savep (point))
          (eol (line-end-position))
          (tok (verilog3-forward-token)))
      (when (and (<= (point) eol) (verilog3-paired-keyword-p :end tok))
        (goto-char savep)
        (verilog3-backward-sexp tok)
        (current-indentation)))))

(defun verilog3-indent-match-pivot-token-rule (pivot-token pivot-point)
  "Calculate indentation when PIVOT-TOKEN indentation should be matched."
  ;; - When `tok' is an empty string, this is a relative indentation case.
  ;; - Stride could meet an `end' keyword when the `end' keyword is unbalanced.
  (when (or (equal pivot-token "")
            (verilog3-paired-keyword-p :end pivot-point))
    (save-excursion
      (goto-char pivot-point)
      (current-indentation))))

(defun verilog3-indent-increase-rule (pivot-token pivot-point)
  "Increase indentation when PIVOT-TOKEN is non-nil."
  (when pivot-token
    (save-excursion
      (goto-char pivot-point)
      (+ (current-indentation) verilog3-indent-offset))))

(defvar verilog3-pre-stride-indent-functions
  '(verilog3-indent-comment-rule
    verilog3-indent-close-keyword-rule
    verilog3-indent-close-paren-rule)
  "This hook is run before `verilog3-backward-stride'. If an indentation rule
does not need the pivot point and doesn't need to be run after a function that
does, putting it in this hook could speed things up.

Each function is called with no argument, shouldn't move point, and should
return either nil if it has no opinion, or an integer representing the column
to which that point should be aligned, if we were to reindent it.")

(defvar verilog3-post-stride-indent-functions
  '(verilog3-indent-begin-special-rule
    verilog3-indent-else-rule
    verilog3-indent-left-aligned-keyword-rule
    verilog3-indent-special-open-keyword-rule
    verilog3-indent-match-pivot-token-rule
    verilog3-indent-inside-paren-rule
    verilog3-indent-increase-rule)
  "This hook is run after `verilog3-backward-stride'.

Each function is called with two arguments: PIVOT-TOKEN and PIVOT-POINT,
shouldn't move point, and should return either nil if it has no opinion, or an
integer representing the column to which that point should be aligned, if we
were to reindent it.")

(defun verilog3-indent-calculate (&optional savep)
  "Calculate indentation for the current line. If SAVEP is specified, set point
to SAVEP before running indentation functions. `verilog3-backward-stride' is
always run from the original point."
  (or (save-excursion
        (when savep (goto-char savep))
        (run-hook-with-args-until-success
         'verilog3-pre-stride-indent-functions))
      (let (pivot-token pivot-point)
        (save-excursion
          (setq pivot-token (verilog3-backward-stride))
          (setq pivot-point (point)))
        (save-excursion
          (when savep (goto-char savep))
          (run-hook-with-args-until-success
           'verilog3-post-stride-indent-functions
           pivot-token pivot-point)))))

(defun verilog3-indent-line ()
  "Indent the current line. If point is before the current indent, move it to
the new indent.

Copied from SMIE."
  (interactive)
  (let* ((savep (point))
         (indent (or (with-demoted-errors
                       (save-excursion
                         (forward-line 0)
                         (skip-chars-forward " \t")
                         (if (>= (point) savep) (setq savep nil))
                         (or (verilog3-indent-calculate)
                             (current-indentation))))
                     (current-indentation))))
    (if (not (numberp indent))
        ;; If something funny is used (e.g. `noindent'), return it.
        indent
      (if (< indent 0) (setq indent 0)) ; Just in case.
      (if savep
          (save-excursion (indent-line-to indent))
        (indent-line-to indent)))))

;;; Major Mode

(define-derived-mode verilog3-mode prog-mode "Verilog3"

  ;; Syntax

  (set-syntax-table verilog3-mode-syntax-table)
  (set (make-local-variable 'comment-start) "// ")
  (set (make-local-variable 'comment-end) "")

  ;; Font Lock

  (setq font-lock-defaults
        `((verilog3-font-lock-keywords
           verilog3-font-lock-keywords-1
           verilog3-font-lock-keywords-2
           verilog3-font-lock-keywords-3)
          nil nil nil))
  (setq font-lock-multiline t)

  ;; Indent
  (setq-local indent-line-function #'verilog3-indent-line))

(provide 'verilog3-mode)
