struct SimpleEM <: DiffEqBase.AbstractSDEAlgorithm end
export SimpleEM

@muladd function DiffEqBase.solve(prob::SDEProblem,alg::SimpleEM,args...;
                          dt = error("dt required for SimpleEM"))

  f = prob.f
  g = prob.g
  u0 = prob.u0
  tspan = prob.tspan
  p = prob.p

  @inbounds begin
      n = Int((tspan[2] - tspan[1])/dt) + 1
      u = [u0 for i in 1:n]
      t = [tspan[1] + i*dt for i in 0:n-1]
      sqdt = sqrt(dt)
  end

  @inbounds for i in 2:n
      uprev = u[i-1]
      tprev = t[i-1]
      if u0 isa Number
          u[i] = uprev + f(uprev,p,tprev)*dt + sqdt*g(uprev,p,tprev)*randn(typeof(u0))
      else
          u[i] = uprev + f(uprev,p,tprev)*dt + sqdt*g(uprev,p,tprev).*randn(typeof(u0))
      end
  end

  sol = DiffEqBase.build_solution(prob,alg,t,u,
                       calculate_error = false)
end
