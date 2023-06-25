function gcd(a::T, b::T) where T<:Integer
    while b > 0
        a, b = b, a % b
    end
    return a
end

function gcd_big(a::T, b::T) where T<:Integer
    u, v = one(T), zero(T); u1, v1 = 0, 1
    #ИНВАРИАНТ:
    while b > 0
        k,r = divrem(a, b)
        a, b = b, r #a - k * b
        u, v, u1, v1 = u1, v1, u - k * u1, v - k * v1
    end
    
    return a, u, v
end

struct Z{T,N}
    a::T
    Z{T,N}(a::T) where {T<:Integer, N} = new(mod(a, N))
end

function inverse(a::Z{T,N}) where {T<:Integer, N}
    if gcd(a.a, N) != 1 
        return nothing
    else
        f, s, d = gcd_big(a.a, N)
        return Z{T,N}(s)
    end 
end

function diaphant(a::T,b::T,c::T) where T<:Integer
    if mod(c,gcd(a,b))!=0
        return nothing
    end
    return gcd_big(a,b)[2:3]
end


Base. +(a::Z{T,N}, b::Z{T,N}) where {T<:Integer, N} = Z{T,N}(a.a + b.a)
Base. -(a::Z{T,N}, b::Z{T,N}) where {T<:Integer, N} = Z{T,N}(a.a - b.a)
Base. *(a::Z{T,N}, b::Z{T,N}) where {T<:Integer, N} = Z{T,N}(a.a * b.a)
Base. -(a::Z{T,N}) where {T<:Integer, N} = Z{T,N}(-a.a)
Base. display(a::Z{T,N}) where {T<:Integer, N} = println(string(a.a))


F = Z{Int, 8}(7)
Q = Z{Int, 5}(9)

print(inverse(Q),"\n")
print(diaphant(3,7,1))
print(F>>T)
