# Untyped Lambda Calculus Interpreter and Visualizer

#### Usage:

Run with `runghc ulc.hs`

Or with `ghci ulc.hs`, `ulc ""` with a term in quotes. Also type `pt` within GHCI to list predefined terms.

#### Grammar:

```
term ::= var
       | /var.term
       | term term
       | (term)
       | <a predefined term>

var ::= <any string not including (, ), /, ., or space, and not a predefined term>
```

#### Sample output:

```
$ runghc ulc.hs
Predefined terms: id, tru, fls, test, and, pair, fst, snd, cn (where n is a number), scc, plus, times, iszro, zz, ss, prd, omega, fix
Enter untyped lambda calculous term: (/n./s./z.s (n s z))(/s./z.s (s z)) succ zero
                          ╭──────App──╮  
                          │           │  
              ╭──────────App──╮      zero
              │               │          
  ╭──────────App──╮          succ        
  │               │                      
 λ n             λ s                     
  │               │                      
 λ s             λ z                     
  │               │                      
 λ z            ╭App──╮                  
  │             │     │                  
╭App──────╮     s   ╭App╮                
│         │         │   │                
s     ╭──App╮       s   z                
      │     │                            
    ╭App╮   z                            
    │   │                                
    n   s                                
---
                      ╭──────App──╮  
                      │           │  
  ╭──────────────────App──╮      zero
  │                       │          
 λ s                     succ        
  │                                  
 λ z                                 
  │                                  
╭App──────────────╮                  
│                 │                  
s             ╭──App╮                
              │     │                
      ╭──────App╮   z                
      │         │                    
     λ s        s                    
      │                              
     λ z                             
      │                              
    ╭App──╮                          
    │     │                          
    s   ╭App╮                        
        │   │                        
        s   z                        
---
      ╭──────────────────────App──╮  
      │                           │  
     λ z                         zero
      │                              
  ╭──App──────────────────╮          
  │                       │          
 succ             ╭──────App╮        
                  │         │        
          ╭──────App──╮     z        
          │           │              
         λ s         succ            
          │                          
         λ z                         
          │                          
        ╭App──╮                      
        │     │                      
        s   ╭App╮                    
            │   │                    
            s   z                    
---
  ╭──App──────────────────╮      
  │                       │      
 succ             ╭──────App──╮  
                  │           │  
          ╭──────App──╮      zero
          │           │          
         λ s         succ        
          │                      
         λ z                     
          │                      
        ╭App──╮                  
        │     │                  
        s   ╭App╮                
            │   │                
            s   z                
---
  ╭──App──────────────────╮      
  │                       │      
 succ         ╭──────────App──╮  
              │               │  
             λ z             zero
              │                  
          ╭──App──────╮          
          │           │          
         succ     ╭──App╮        
                  │     │        
                 succ   z        
---
  ╭──App──────╮              
  │           │              
 succ     ╭──App──────╮      
          │           │      
         succ     ╭──App──╮  
                  │       │  
                 succ    zero
done
```

```
$ ghci ulc.hs
...
*ULC> pt
Predefined terms: id, tru, fls, test, and, pair, fst, snd, cn (where n is a number), scc, plus, times, iszro, zz, ss, prd, omega, fix
*ULC> ulc "fst (pair firstThing secondThing)"
  ╭────App────────────────────────╮            
  │                               │            
 λ p                ╭────────────App─────╮     
  │                 │                    │     
╭App─╮          ╭──App─────╮        secondThing
│    │          │          │                   
p   λ t        λ f     firstThing              
     │          │                              
    λ f        λ s                             
     │          │                              
     t         λ b                             
                │                              
            ╭──App╮                            
            │     │                            
          ╭App╮   s                            
          │   │                                
          b   f                                
---
  ╭────App────────────────────╮            
  │                           │            
 λ p                      ╭──App─────╮     
  │                       │          │     
╭App─╮                   λ s    secondThing
│    │                    │                
p   λ t                  λ b               
     │                    │                
    λ f     ╭────────────App╮              
     │      │               │              
     t    ╭App─────╮        s              
          │        │                       
          b    firstThing                  
---
  ╭────App────────────────╮            
  │                       │            
 λ p                     λ b           
  │                       │            
╭App─╮      ╭────────────App─────╮     
│    │      │                    │     
p   λ t   ╭App─────╮        secondThing
     │    │        │                   
    λ f   b    firstThing              
     │                                 
     t                                 
---
                ╭────────────App─╮ 
                │                │ 
               λ b              λ t
                │                │ 
  ╭────────────App─────╮        λ f
  │                    │         │ 
╭App─────╮        secondThing    t 
│        │                         
b    firstThing                    
---
    ╭────────────App─────╮     
    │                    │     
 ╭─App─────╮        secondThing
 │         │                   
λ t    firstThing              
 │                             
λ f                            
 │                             
 t                             
---
     ╭─────App─────╮     
     │             │     
    λ f       secondThing
     │                   
 firstThing              
---
 firstThing
done
```