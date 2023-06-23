#=
1. Написать функцию, вычисляющую n-ю частичную сумму ряда Телора
(Маклорена) функции для произвольно заданного значения аргумента x.
Сложность алгоритма должна иметь оценку .
=#

function exp_partial_sum(x::Real, n::Int)
    sum = 0.0
    term = 1.0
    for i in 0:n
        sum += term
        term *= x / (i + 1)
    end
    return sum
end

println(exp_partial_sum(5.0, 6))

#=
2. Написать функцию, вычиляющую значение с машинной точностью (с
максимально возможной в арифметике с плавающей точкой).
=#

function exp_with_max_precision(x) ####
    y = 1.0
    term = 1.0
    k = 1
    while y + term != y ######
        term *= x / k
        y += term
        k += 1
    end
    return y
end

println(exp_with_max_precision(5.0))

#=
3. Написать функцию, вычисляющую функцию Бесселя (обобщение функции синуса, колебание струны 
с переменным толщеной, натяжением) 
заданного целого неотрицательного порядка по ее ряду Тейлора с машинной точностью. Для
этого сначала вывести соответствующую рекуррентную формулу,
обеспечивающую возможность эффективного вычисления. Построить
семейство графиков этих функций для нескольких порядков, начиная с нулевого
порядка.
=#

#j(x) = (x/2)^j * sum((-1)^k / (k! * (j + k)!) * (x/2)^(2k), k=0:inf)
#j - порядок, x - аргумент
using Plots
function bessel(M::Integer, x::Real)
    sqrx = x*x
    a = 1/factorial(M)
    m = 1
    s = 0 
    
    while s + a != s
        s += a
        a = -a * sqrx /(m*(M+m)*4)
        m += 1
    end
    
    return s*(x/2)^M
end

values = 0:0.1:20
myPlot = plot()
for m in 0:5
	plot!(myPlot, values, bessel.(m, values))
end
display(myPlot)



#=
4. Реализовать алгорим, реализующий обратный ход алгоритма Жордана-Гаусса
=#
using LinearAlgebra
function shordan_gauss(A::AbstractMatrix{T}, b::AbstractVector{T})::AbstractVector{T} where T
    @assert size(A, 1) == size(A, 2)
    n = size(A, 1) 
    x = zeros(T, n)

    for i in n:-1:1
        x[i] = b[i]
        for j in i+1:n
            x[i] =fma(-x[j] ,A[i,j] , x[i])
        end
        x[i] /= A[i,i]
    end
    return x
end

#=
5. Реализовать алгоритм, осуществляющий приведение матрицы матрицы к ступенчатому виду
=#
function TransformToSteps!(matrix::AbstractMatrix, epsilon::Real = 1e-7)::AbstractMatrix
	@inbounds for k ∈ 1:size(matrix, 1)
		absval, Δk = findmax(abs, @view(matrix[k:end,k]))

		(absval <= epsilon) && throw("Вырожденая матрица")

		Δk > 1 && swap!(@view(matrix[k,k:end]), @view(matrix[k+Δk-1,k:end]))

		for i ∈ k+1:size(matrix,1)
			t = matrix[i,k]/matrix[k,k]
			@. @views matrix[i,k:end] = matrix[i,k:end] - t * matrix[k,k:end] # Макрос @. используется вместо того, чтобы в соответсвующей строчке каждую операцию записывать с точкой
		end
	end

	return matrix
end


#Проверка:
#matrix = [1.0 2.0 3.0;1.0 6.0 9.0;-1.0 2.0 4.0]
#values = [-1.0, 2.0, 2.0]
#=println("--Матрица--")
display(matrix)
println("--Свободные члены--")
display(values)
println("--Обратный ход Гаусса--")
display(ReverseGauss!(matrix,values))=#
