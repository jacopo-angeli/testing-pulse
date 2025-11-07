module Part1.GettingOffTheGround

let incr (x: int) : int = x + 1



// Provide an implementation of max coupled with a type that is precise enough 
// to rule out definitions that do not correctly return the maximum of x and y.

val max (x y: int) : z: int{z >= x /\ z >= y /\ (z = x \/ z = y)}

let max x y = if x >= y then x else y

open FStar.Mul

val factorial (n: nat) : (n': nat{(n == 0 ==> n' == 1) /\})

let rec factorial n = if n = 0 then 1 else n * factorial (n - 1)

val fibonacci (n: nat) : r: nat{r >= 0 /\ (n == 0 ==> r == 1) /\ (n == 1 ==> r == 1)}

let rec fibonacci n = if n <= 1 then 1 else fibonacci (n - 1) + fibonacci (n - 2)