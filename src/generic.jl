# Generic concepts and functions

# a premetric is a function d that satisfies:
#
#   d(x, y) >= 0
#   d(x, x) = 0
#
abstract PreMetric

# a semimetric is a function d that satisfies:
#
#   d(x, y) >= 0
#   d(x, x) = 0
#   d(x, y) = d(y, x)
#
abstract SemiMetric <: PreMetric

# a metric is a semimetric that satisfies triangle inequality:
#
#   d(x, y) + d(y, z) >= d(x, z)
#
abstract Metric <: SemiMetric


# Generic functions

result_type(::PreMetric, T1::Type, T2::Type) = promote_type(T1, T2)


# Generic column-wise evaluation

function colwise!(r::AbstractArray, metric::PreMetric, a::AbstractVector, b::AbstractMatrix)
    n = size(b, 2)
    if length(r) != n
        throw(ArgumentError("Incorrect size of r."))
    end
    for j = 1 : n
        r[j] = evaluate(metric, a, b[:,j])
    end
end

function colwise!(r::AbstractArray, metric::PreMetric, a::AbstractMatrix, b::AbstractVector)
    n = size(a, 2)
    if length(r) != n
        throw(ArgumentError("Incorrect size of r."))
    end
    for j = 1 : n
        r[j] = evaluate(metric, a[:,j], b)
    end
end

function colwise!(r::AbstractArray, metric::PreMetric, a::AbstractMatrix, b::AbstractMatrix)
    n = get_common_ncols(a, b)
    if length(r) != n
        throw(ArgumentError("Incorrect size of r."))
    end
    for j = 1 : n
        r[j] = evaluate(metric, a[:,j], b[:,j])
    end
end

function colwise!(r::AbstractArray, metric::SemiMetric, a::AbstractMatrix, b::AbstractVector)
    colwise!(r, metric, b, a)
end

function colwise(metric::PreMetric, a::AbstractMatrix, b::AbstractMatrix)
    n = get_common_ncols(a, b)
    r = Array(result_type(metric, eltype(a), eltype(b)), n)
    colwise!(r, metric, a, b)
    return r
end

function colwise(metric::PreMetric, a::AbstractVector, b::AbstractMatrix)
    n = size(b, 2)
    r = Array(result_type(metric, eltype(a), eltype(b)), n)
    colwise!(r, metric, a, b)
    return r
end

function colwise(metric::PreMetric, a::AbstractMatrix, b::AbstractVector)
    n = size(a, 2)
    r = Array(result_type(metric, eltype(a), eltype(b)), n)
    colwise!(r, metric, a, b)
    return r
end


# Generic pairwise evaluation

function pairwise!(r::AbstractMatrix, metric::PreMetric, a::AbstractMatrix, b::AbstractMatrix)
    na = size(a, 2)
    nb = size(b, 2)
    if !(size(r) == (na, nb))
        throw(ArgumentError("Incorrect size of r."))
    end
    for j = 1 : size(b, 2)
        bj = b[:,j]
        for i = 1 : size(a, 2)
            r[i,j] = evaluate(metric, a[:,i], bj)
        end
    end
end

function pairwise!(r::AbstractMatrix, metric::PreMetric, a::AbstractMatrix)
    pairwise!(r, metric, a, a)
end

function pairwise!(r::AbstractMatrix, metric::SemiMetric, a::AbstractMatrix)
    n = size(a, 2)
    if !(size(r) == (n, n))
        throw(ArgumentError("Incorrect size of r."))
    end
    for j = 1 : n
        aj = a[:,j]
        for i = j+1 : n
            r[i,j] = evaluate(metric, a[:,i], aj)
        end
        r[j,j] = 0
        for i = 1 : j-1
            r[i,j] = r[j,i]   # leveraging the symmetry of SemiMetric
        end
    end
end

function pairwise(metric::PreMetric, a::AbstractMatrix, b::AbstractMatrix)
    m = size(a, 2)
    n = size(b, 2)
    r = Array(result_type(metric, eltype(a), eltype(b)), (m, n))
    pairwise!(r, metric, a, b)
    return r
end

function pairwise(metric::PreMetric, a::AbstractMatrix)
    n = size(a, 2)
    r = Array(result_type(metric, eltype(a), eltype(a)), (n, n))
    pairwise!(r, metric, a)
    return r
end

function pairwise(metric::SemiMetric, a::AbstractMatrix)
    n = size(a, 2)
    r = Array(result_type(metric, eltype(a), eltype(a)), (n, n))
    pairwise!(r, metric, a)
    return r
end

