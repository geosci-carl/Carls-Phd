# ABM model by Carl Fredrick G. Aquino
# Started 2022-12-05

## 1 - Intro ###################################################################
println("Intro")
# install Agents.jl to use ABMs
# using Pkg; Pkg.add("Agents")

# install dataframes
# using Pkg; Pkg.add("DataFrames")

## 2 - Initialize Model ###################################################################
println("Initialize Model")

# model configuration
numyears = 15 # duration of simulation in years

# farmer configuration
numagents = 4 # number of farmers
covercrop_initial = (false,true,false,false) # Do the farmers initially plant covercrops? true or false
group_initial = [1,2,2,2] # which groups do the farmers belong to? see 'farming groups' below 

# farming groups (1= corn, 2= soybeans, 3= wheat, 4= hay) 
group1 = [4,4,4,4,4,1,2,3] # with hay, 5-year production
group2 = [1,2,3] # without hay

# cover crop scenario
covercrop_require = false # initially require covercrop? true/false
year_covercrop_require = 9 # require cover crops beginning at n = 9 years

## 3 - Create Agent-Based Model ###################################################################
println("Create ABM")
using Agents
using DataFrames

# Create space
space = GridSpaceSingle((10, 10); periodic = false)

# Create agent type - 
@agent Farmer GridAgent{2} begin 
    covercrop::Bool # Attitude towards cover crop
    group::Int # The group of the agent, determines behavior.
end

# Create ABM
year = 1 # initialize model
properties = Dict(
    :year_covercrop_require => year_covercrop_require,
    :year => year,
    :covercrop_require => covercrop_require
    )
model = ABM(Farmer, space; properties)

# Populate ABM with agents
for n in 1:numagents
    agent = Farmer(n, (1,1), covercrop_initial[n], group_initial[n])
    add_agent_single!(agent, model)
end

## 4 - Create Step Functions ###################################################################
println("Create Step Function")
# Model step function
function model_step!(model)
    model.year = model.year + 1 # for each time step, the year progresses by one

    if model.year >= model.year_covercrop_require # if we hit the prescribed covercrop year,
        model.covercrop_require = true # change covercrop requirement to TRUE
    end

end

# Agent step function
function agent_step!(agent, model)
    if model.covercrop_require==true # if covercrop requirement is TRUE,
        agent.covercrop=true # use covercrop
    end

end

## 5 - Run the Model ###################################################################
println("Run Model")
# Agents.step!(model, agent_step!, model_step!, numyears)
adata = [:covercrop]
agent_df = run!(model, agent_step!, model_step!, numyears; adata)
df_out = agent_df[1]

results = zeros(numyears,numagents)

# slicing
for n in 1:numyears
    if n==1
        a=n
        b=a+3
    else
        a=(1+(4*(n-1)))
        b=a+3
    end


results[n,:] = df_out[a:b,3]
end

println("End of Code")