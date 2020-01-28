module ULC where

import Data.List
import Text.Read

data T = Var String
       | Abs String T
       | App T T
  deriving (Show, Eq)

data Syntax = Paren Syntax Syntax
            | Lam String Syntax
            | Name String Syntax
            | End
  deriving (Show, Eq)

-- Printing

leftSpace :: String -> String
leftSpace s = if mod (length s) 2 == 0 then " " else ""

spaces :: Int -> String
spaces i = replicate i ' '

sidebars :: Int -> String
sidebars i = replicate i '─'

extend :: Int -> Int -> [String] -> [String]
extend n sp ss = ss ++ (replicate n (spaces sp))

printT' :: T -> (Int, Int, [String])
printT' (Var s) =
  let i = div (length s) 2
  in (i, i, [(leftSpace s) ++ s])
printT' (Abs s t) =
  let i = div (2 + length s) 2
      (jl, jr, ss) = printT' t
      il = max i jl
      ir = max i jr
  in (il, ir,
       ((spaces (il - i)) ++ (leftSpace s) ++ "λ " ++ s ++ (spaces (ir - i)))
       : ((spaces il) ++ "│" ++ (spaces ir))
       : (map (\x -> (spaces (il - jl)) ++ x ++ (spaces (ir - jr))) ss)
     )
printT' (App t1 t2) =
  let (j1l, j1r, ss1) = printT' t1
      (j2l, j2r, ss2) = printT' t2
      e = (length ss1) - (length ss2)
      ss = if e > 0 then zip ss1 (extend e (j2l + 1 + j2r) ss2) else zip (extend (-e) (j1l + 1 + j1r) ss1) ss2
  in (j1l + 2 + j1r, j2l + 2 + j2r,
       ((spaces j1l) ++ "╭" ++ (sidebars j1r) ++ "App" ++ (sidebars j2l) ++ "╮" ++ (spaces j2r))
       : ((spaces j1l) ++ "│" ++ (spaces (j1r + 3 + j2l)) ++ "│" ++ (spaces j2r))
       : (map (\(x1, x2) -> x1 ++ "   " ++ x2) ss)
     )

printT :: T -> String
printT t =
  let (_,_,r) = printT' t
  in intercalate "\n" r

-- Evaluating

substitute :: T -> T -> String -> T
substitute (Var s') t s | s == s' = t
substitute (Abs s' t') t s | s /= s' = (Abs s' (substitute t' t s))
substitute (App t1 t2) t s = (App (substitute t1 t s) (substitute t2 t s))
substitute t _ _ = t

evalOneStep :: T -> (Bool, T)
evalOneStep (App t1 t2) =
  let (b1, e1) = evalOneStep t1
  in if b1
     then (True, (App e1 t2))
     else let (b2, e2) = evalOneStep t2
          in if b2
             then (True, (App e1 e2))
             else
               case e1 of
                 (Abs s t) -> let r = substitute t e2 s
                              in (True, r)
                 _ -> (False, (App e1 e2))
evalOneStep t = (False, t)

evalPrint :: T -> IO ()
evalPrint t =
  let (b, t') = (evalOneStep t)
  in if b
     then do putStr $ (printT t) ++ "\n---"
             getLine
             evalPrint t'
     else do putStrLn $ printT t
             putStrLn "done\n"
             return ()

-- Parsing

tokenizeVar :: String -> (String, String)
tokenizeVar "" = ("","")
tokenizeVar s@('.':ss) = ("", s)
tokenizeVar s@(' ':ss) = ("", s)
tokenizeVar s@('(':ss) = ("", s)
tokenizeVar s@(')':ss) = ("", s)
tokenizeVar (s:ss) = let (f,s') = (tokenizeVar ss)
                   in (s:f,s')
                       
tokenize :: String -> [String]
tokenize [] = []
tokenize ('(':ss) = "(":(tokenize ss)
tokenize ('/':ss) = "/":(tokenize ss)
tokenize ('.':ss) = ".":(tokenize ss)
tokenize (')':ss) = ")":(tokenize ss)
tokenize (s:ss) | s == ' ' || s == '\n' || s == '\t' = tokenize ss
tokenize s = let (f,s') = tokenizeVar s
             in f:(tokenize s')

churchNumeral :: Int -> String
churchNumeral 1 = "s z"
churchNumeral n | n < 1 = "z"
churchNumeral n = "s (" ++ (churchNumeral (n-1)) ++ ")"

parse1 :: [String] -> (Syntax, [String])
parse1 [] = (End, [])
parse1 ("(":ts) = let (s1, ts1) = parse1 ts
                      (s2, ts2) = parse1 ts1
                  in (Paren s1 s2, ts2)
parse1 (")":ts) = (End, ts)
parse1 ("/":l:".":ts) = let (s, ts') = parse1 ts
                       in (Lam l s, ts')
parse1 ("id":ts) = parse1 ((tokenize "(/x.x)")++ts)
parse1 ("tru":ts) = parse1 ((tokenize "(/t./f.t)")++ts)
parse1 ("fls":ts) = parse1 ((tokenize "(/t./f.f)")++ts)
parse1 ("test":ts) = parse1 ((tokenize "(/l./m./n.l m n)")++ts)
parse1 ("and":ts) = parse1 ((tokenize "(/b./c.b c fls)")++ts)
parse1 ("pair":ts) = parse1 ((tokenize "(/f./s./b.b f s)")++ts)
parse1 ("fst":ts) = parse1 ((tokenize "(/p.p tru)")++ts)
parse1 ("snd":ts) = parse1 ((tokenize "(/p.p fls)")++ts)
parse1 (('c':n):ts) | ((readMaybe n) :: Maybe Int) /= Nothing = parse1 ((tokenize $ "(/s./z." ++ (churchNumeral (read n)) ++ ")")++ts)
parse1 ("scc":ts) = parse1 ((tokenize "(/n./s./z.s (n s z))")++ts)
parse1 ("plus":ts) = parse1 ((tokenize "(/m./n./s./z.m s (n s z))")++ts)
parse1 ("times":ts) = parse1 ((tokenize "(/m./n.m (plus n) c0)")++ts)
parse1 ("iszro":ts) = parse1 ((tokenize "(/m.m (/x.fls) tru)")++ts)
parse1 ("zz":ts) = parse1 ((tokenize "(pair c0 c0)")++ts)
parse1 ("ss":ts) = parse1 ((tokenize "(/p.pair (snd p) (plus c1 (snd p)))")++ts)
parse1 ("prd":ts) = parse1 ((tokenize "(/m.fst (m ss zz))")++ts)
parse1 ("omega":ts) = parse1 ((tokenize "((/x.x x)(/x.x x))")++ts)
parse1 ("fix":ts) = parse1 ((tokenize "(/f.(/x.f (/y.x x y))(/x.f (/y.x x y)))")++ts)
parse1 (n:ts) = let (s, ts') = parse1 ts
                in (Name n s, ts')

parse2App :: T -> Syntax -> (T, Syntax)
parse2App t (Paren s1 s2) = parse2App (App t (fst $ parse2 s1)) s2
parse2App t (Lam n s) = (App t $ Abs n $ fst $ parse2 s, End)
parse2App t (Name n s) = parse2App (App t (Var n)) s
parse2App t End = (t, End)

parse2 :: Syntax -> (T, Syntax)
parse2 (Paren s1 s2) = parse2App (fst $ parse2 s1) s2
parse2 (Lam n s) = (Abs n $ fst $ parse2 s, End)
parse2 (Name n s) = parse2App (Var n) s

-- Running

pt :: IO ()
pt = putStrLn "Predefined terms: id, tru, fls, test, and, pair, fst, snd, cn (where n is a number), scc, plus, times, iszro, zz, ss, prd, omega, fix"

ulc :: String -> IO ()
ulc = evalPrint . fst . parse2 . fst . parse1 . tokenize

main :: IO ()
main = do
  pt
  putStr "Enter untyped lambda calculous term: "
  t <- getLine
  ulc t
