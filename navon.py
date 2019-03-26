'''
Modified visual Navon task
Author: Jeremy Yeaton
24 March 2019
'''

import expyriment as xpy, random as rnd, copy

xpy.control.set_develop_mode(True)
exp = xpy.design.Experiment(name="Navon")
xpy.control.initialize(exp)

n_scrambles = 1

'''
detect O, S, or H at either the local or global level
task switching?
'''
globalLetters = ['O','S','H','L','A']
localLetters = ['O','S','H','L','A']

trial_types = []
for globLet in globalLetters:
	for locLet in localLetters:
		trial_types.append(''.join([globLet,locLet]))	
trial_types

globDict = {
'H':[[1,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,1],
	[1,0,1,.5,1,.5,1,0,1],
	[1,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,1]],
'O':[[1,1,1,1,1,1],
	[1,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,1],
	[1,1,1,1,1,1]],
'L':[[1,0,0,0,0,0,0,0],
	[1,0,0,0,0,0,0,0],
	[1,0,0,0,0,0,0,0],
	[1,0,0,0,0,0,0,0],
	[1,0,0,0,0,0,0,0],
	[1,0,0,0,0,0,0,0],
	[1,1,1,1,1,1,1]],
'S':[[0,1,1,1,1,1,0],
	[1,0,0,0,0,0,0,1],
	[0,1,1,0,0,0,0,0],
	[0,0,1,1,1,0,0,0],
	[0,0,0,0,0,1,1,0],
	[1,0,0,0,0,0,0,1],
	[0,1,1,1,1,1,0]],
'A':[[0,0,0,1],
	[1,0,1],
	[1,0,0,0,0,0,1],
	[1,1,1,1,1],
	[1,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,1],
	[1,0,0,0,0,0,0,0,0,0,1]]
}

def mkTrial(trial_name, block_name):
	templates = copy.deepcopy(globDict)
	t_name = trial_name
	glob = t_name[0]
	loc = t_name[1]
	temp = templates[glob]
	trial_name = xpy.design.Trial()
	for lIdx,line in enumerate(temp):
		for cIdx, i in enumerate(line):
			if i == 1:
				temp[lIdx][cIdx] = loc
			elif i == .5:
				temp[lIdx][cIdx] = " "
			else:
				temp[lIdx][cIdx] = "  "
	for Idx, line in enumerate(temp):
		temp[Idx] = ''.join(line)
	txt = '\n'.join(temp)
	stim = xpy.stimuli.TextBox(txt,(300,300),text_size = 30, text_bold = True,text_justification = 1)
	stim.preload()
	trial_name.add_stimulus(stim)
	trial_name.set_factor(name = "Type", value = t_name)
	trial_name.set_factor(name = "Global", value = glob)
	trial_name.set_factor(name = "Local", value = loc)
	block_name.add_trial(trial_name)


#def addBlock(block):
#	blockNum = block
#	block = xpy.design.Block(name = block)
#	trials = xpy.design.randomize.make_multiplied_shuffled_list(trial_types[blockNum],n_scrambles)
#	for trial in trials:
#		if trial[1] == 'R':
#			rectTrial(trial,block)
#		elif trial[1] == 'W':
#			bwTrial(trial,block)
#		else:
#			clrTrial(trial,block)
#	exp.add_block(block)

def presentBlock(block_start,block_stop):
	for block in exp.blocks[block_start:block_stop]:
		cross.present()
		for trial in block.trials:
			cross.present(clear = False, update = True)
			exp.clock.wait(rnd.randint(500,1000))
			trial.stimuli[0].present(clear = True, update= True)
			key, rt = exp.keyboard.wait([xpy.misc.constants.K_d,
										  xpy.misc.constants.K_j])
#										,duration = 1500)
			exp.data.add([block.name, trial.id, trial.get_factor("Type"), 
					trial.get_factor("Global"), trial.get_factor("Local"),
					key, rt])
			blank.present(clear = True, update= False)
			exp.clock.wait(500)
	
cross = xpy.stimuli.FixCross((25,25),(0,0),4)
cross.preload()

blank = xpy.stimuli.BlankScreen()
blank.preload()

block = xpy.design.Block(name = 'B1')
#trials = xpy.design.randomize.make_multiplied_shuffled_list(trial_types[blockNum],n_scrambles)
trials = ['AA','HO','LH','SS','OL']
for trial in trials:
	mkTrial(trial,block)
exp.add_block(block)

exp.data_variable_names = ["Block", "Trial", "Type", "Global", "Local", "Key", "RT"]

xpy.control.start(skip_ready_screen = True)
blNum = 0
presentBlock(blNum,blNum + 1)

xpy.control.end()