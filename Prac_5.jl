#Practic5###############################################################################################
# Пузырьковая сортировка O( n^2 )
function bubble_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    n = length(array)

    for k in 1:n-1
        istranspose = false

        for i in 1:n-k
            if array[i]>array[i+1]
                array[i], array[i+1] = array[i+1], array[i]
                istranspose = true
            end
        end

        if istranspose == false
            break
        end
    end

    return array
end

bubble_sort(array::AbstractVector)::AbstractVector = bubble_sort!(copy(array))

#1. Реализовать функции, аналогичные встроенным функциям sort, sort!, sortperm, sortperm! на основе алгоритма сортировки вставками.
# При этом, при проектировании функциий, аналогичных функциям sort и sort!, требуется избежать повторного кодирования алгоритма сортировки.
# То же относится и к проектированию пары функций, аналогичных функциям sortperm, sortperm!

# Сортировка вставками O( n^2 )
function insert_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    n = 1
    # Инвариант: срез array[1:n] - отсортирован

    while n < length(array) 
        n += 1
        i = n

        while i > 1 && array[i-1] > array[i]
            array[i], array[i-1] = array[i-1], array[i]
            i -= 1
        end

        # Утверждение: array[1] <= ... <= array[n]
    end

    return array
end

insert_sort(array::AbstractVector)::AbstractVector = insert_sort!(copy(array))

#2. Реализовать алгоритм сортировки "расчесыванием", который базируется на сортировке "пузырьком". Исследовать эффективность этого алгоритма в равнении с пузырьковой сортировкой (на больших массивах делать времннные замеры).

# Сортировка расчёской O( n^2 )
function comb_sort!(array::AbstractVector{T}, factor::Real=1.2473309) where T <: Number 
    step = length(array)

    while step >= 1
        for i in 1:length(array)-step
            if array[i] > array[i+step]
                array[i], array[i+step] = array[i+step], array[i]
            end
        end
        step = Int(floor(step/factor))
    end

    # Теперь массив почти упорядочен, осталось сделать всего несколько итераций внешнего цикла в bubble_sort!(array)
    bubble_sort!(array)
end

comb_sort(array::AbstractVector, factor::Real=1.2473309)::AbstractVector = comb_sort!(copy(array),factor)

#3. Реализовать алгоритм сортировки Шелла, который базируется на сортировке вставками.
# Исследовать эффективность этого алгоритма в равнении с сортировкой вставками (на больших массивах делать времннные замеры).

# Сортировка Шелла O( n^2 )
function shell_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
    n = length(array)

	# Здесь последовательность шагов прореживания массива определяется генератором
    step_series = (n÷2^i for i in 1:Int(floor(log2(n)))) 

    for step in step_series
        for i in firstindex(array):step-1
            insert_sort!(@view array[i:step:end]) # - сортировка вставками выделенного (прореженного) подмассива
        end
    end
    return array
end

shell_sort(array::AbstractVector)::AbstractVector = shell_sort!(copy(array))

#4. Реализовать алгоритм сортировки слияниями. Исследовать эффективность этого алгоритма в сравнении с предыдущми алгоритмами.

# @inline - делает функцию "встраиваемой", т.е. во время компиляции ее тело будет встроено непосредственно в код вызывающей функции (за счет этого происходит экономия на времени, затрачиваемым на вызов функции; это время очень небольшое, но тем не менее)
@inline function Base.merge!(a1, a2, a3)::Nothing
    i1, i2, i3 = 1, 1, 1
    @inbounds while i1 <= length(a1) && i2 <= length(a2) # @inbounds - передотвращает проверки выхода за пределы массивов
        if a1[i1] < a2[i2]
            a3[i3] = a1[i1]
            i1 += 1
        else
            a3[i3] = a2[i2]
            i2 += 1
        end
        i3 += 1
    end
    @inbounds if i1 > length(a1)
        a3[i3:end] .= @view(a2[i2:end]) # Если бы тут было: a3[i3:end] = @view(a2[i2:end]), то это привело бы к лишним аллокациям (к созданию промежуточного массива)
    else
        a3[i3:end] .= @view(a1[i1:end])
    end
    nothing
end

# Сортировка слияниями O( n*log(n) )
function merge_sort!(array::AbstractVector{T})::AbstractVector{T} where T <: Number
	b = similar(array) # - вспомогательный массив того же размера и типа, что и массив array
	N = length(array)
	n = 1 # n - текущая длина блоков

	@inbounds while n < N
		K = div(N,2n) # - число имеющихся пар блоков длины n
		for k in 0:K-1
			merge!(@view(array[(1:n).+k*2n]), @view(array[(n+1:2n).+k*2n]), @view(b[(1:2n).+k*2n]))
		end
		if N - K*2n > n # - осталось еще смержить блок длины n и более короткий остаток
			merge!(@view(array[(1:n).+K*2n]), @view(array[K*2n+n+1:end]), @view(b[K*2n+1:end]))
		elseif 0 < N - K*2n <= n # - оставшуюся короткую часть мержить не с чем
			b[K*2n+1:end] .= @view(array[K*2n+1:end])
		end
		array, b = b, array
		n *= 2
	end

	if isodd(log2(n)) # - если цикл был выполнен нечетное число раз, то b - это исходная ссылка на массив (на внешний массив), и array - это ссылка на вспомогательный массив (локальный)
		b .= array # b = copy(array) - это было бы не то же самое, т.к. при этом получилась бы ссылка на новый массив, который создает функция copy
		array = b
	end

	return array # - исходная ссылка на внешний массив (проверить, что это так, можно с помощью ===)
end

merge_sort(array::AbstractVector)::AbstractVector = merge_sort!(copy(array))



# Использую модуль Random для генерации случайного массива
using Random

A = randperm(100000)[1:100000]

@showtime bubble_sort(A)
@showtime insert_sort(A)
@showtime comb_sort(A)
@showtime shell_sort(A)
@showtime merge_sort(A)
@showtime quick_sort(A)

#= Топ сортировок 
bubble_sort(A): 9.740503 seconds (21.70 k allocations: 1.927 MiB, 0.14% compilation time)
insert_sort(A): 1.242766 seconds (7.11 k allocations: 1.119 MiB, 0.82% gc time, 1.25% compilation time)
comb_sort(A): 0.023961 seconds (20.77 k allocations: 1.875 MiB, 68.58% compilation time)
shell_sort(A): 0.108704 seconds (124.69 k allocations: 7.244 MiB, 43.83% compilation time)
merge_sort(A): 0.262546 seconds (831.54 k allocations: 38.854 MiB, 97.07% compilation time)
quick_sort(A): 0.083688 seconds (375.24 k allocations: 18.645 MiB, 14.96% gc time, 89.28% compilation time)
=#

@showtime sort(A,alg=InsertionSort)
@showtime sort(A,alg=QuickSort)
@showtime sort(A,alg=MergeSort)

#= Библиотечные сортировки
sort(A, alg = InsertionSort): 1.206621 seconds (63.45 k allocations: 4.079 MiB, 2.13% compilation time)
sort(A, alg = QuickSort): 0.017171 seconds (15.88 k allocations: 1.670 MiB, 73.98% compilation time)
sort(A, alg = MergeSort): 0.051416 seconds (155.36 k allocations: 8.990 MiB, 89.43% compilation time)
=#
