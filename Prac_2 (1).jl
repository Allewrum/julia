function pow(a, n :: Int)   # t*a^n = const
    t = one(a)
    while n>0
        if mod(n, 2) == 0
            n/=2
            a *= a 
        else
            n -= 1
            t *= a
        end
    end  
    return t
end

struct Matrix{T}
    a11 :: T
    a12 :: T
    a21 :: T
    a22 :: T
end

Matrix{T}() where T = Matrix{T}(zero(T), zero(T), zero(T), zero(T))

Base. one(::Type{Matrix{T}}) where T = Matrix{T}(one(T), zero(T), zero(T), one(T))

Base. one(M :: Matrix{T}) where T = Matrix{T}(one(T), zero(T), zero(T), one(T))

Base. zero(::Type{Matrix{T}}) where T = Matrix{T}()

function Base. *(M1 :: Matrix{T}, M2 :: Matrix{T}) where T
    a11 = M1.a11 * M2.a11 + M1.a12 * M2.a21
    a12 = M1.a11 * M2.a12 + M1.a12 * M2.a22
    a21 = M1.a21 * M2.a11 + M1.a22 * M2.a21
    a22 = M1.a21 * M2.a12 + M1.a22 * M2.a22
    Res = Matrix{T}(a11, a12, a21, a22)
    return Res
end

function fibonachi(n :: Int)
    Tmp = Matrix{Int}(1, 1, 1, 0) 
    Tmp = pow(Tmp, n)
    return Tmp.a11    
end

#
function log(a, x, e) # a > 1        
    z = x
    t = 1
    y = 0
    #ИНВАРИАНТ z^t * a^y = x
    while z < 1/a || z > a || t > e 
        if z < 1/a
            z *= a 
            y -= t 
        elseif z > a
            z /= a
            y += t
        elseif t > e
            t /= 2 
            z *= z 
        end
    end
    return y
end


function bisection(f::Function, a, b, epsilon)
    if f(a)*f(b) < 0 && a < b
        f_a = f(a)
        #ИНВАРИАНТ: f_a*f(b) < 0
        while b-a > epsilon
            t = (a+b)/2
            f_t = f(t)
            if f_t == 0
                return t
            elseif f_a*f_t < 0
                b=t
            else
                a, f_a = t, f_t
            end
        end  
        return (a+b)/2
    else
        @warn("Некоректные данные")
    end
end





bisection(x->cos(x)-x, 0, 1, 1e-8)


function newton(r::Function, x, epsilon, num_max = 10)
    dx = -r(x)
    k=0
    while abs(dx) > epsilon && k <= num_max
        x += dx
        dx = -r(x)
        k += 1
    end
    k > num_max && @warn("Требуемая точность не достигнута")
    return x
end

f(x) = cos(x) - x

r(x) = -f(x)/(sin(x)+1)


p(x) = 6*x^5 - 23*x^4 + 12*x^2 + 86

rp(x) = p(x) / (30*x^4 - 92*x^3 + 24*x)



function fast_power(a::T,n::Integer)where T
    p,k,t = a,n,one(T)
    while k > 0
        if iseven(k) #Четное
            k /=2
            p*=p
        else
            k -= 1
            t *= p
        end
    end
    return t
end




function TestPr2()
    println(fast_power(2,20))
    println(fast_fib(30))
    println(bisection(x->x+2,-10,10,0.003))
    println(bisection(x->cos(x) - x, -10,10,0.003))
    println()
    println("tut1 ",eyler(5))
    println("tut2 ",eyler2(3)) #плохая точность
    println("tut3 ",exp(1)^2)
    println("tut4 ",fast_power(exp(1),2))
    println(1 + 0.00000000000000001 == 1)
    println(logariphm(0.1,2,00000000000.1))

    return round((fast_power((1+sqrt(5))/2,n) - fast_power((1-sqrt(5))/2,n))/sqrt(5))
end


