'''
Modified Navon visual task
Author: Jeremy Yeaton
24 March 2019
'''

import expyriment as xpy, random as rnd, copy

xpy.control.set_develop_mode(True)
exp = xpy.design.Experiment(name="Navon")
xpy.control.initialize(exp)

n_scrambles = 1

'''
implement practice
discuss time in instructions
'''
blocks = ['globLoc','glob','loc','inverse']
globalLetters = ['O','S','H','L','A']
localLetters = ['O','S','H','L','A']

repKeys = {'F':[xpy.misc.constants.K_f,102],
		   'J':[xpy.misc.constants.K_j,106]}

detect = rnd.choice([key for key in repKeys])
falseKey = 'F'
if detect == 'F':
	falseKey = 'J'
targets = rnd.choices(globalLetters,k=2)

trial_types = []
for globLet in globalLetters:
	locLet = 'A'
#	for locLet in localLetters:
	trial_types.append(''.join([globLet,locLet]))
		
globLocInstr = """Vous verrez des grandes lettres sur l'ecran.
Ces lettres sont composees des lettres plus petites.
Si la grande OU la petite sont un %s ou un %s
Appuyez sur %s.
Sinon, appuyez sur %s.\n
Appuyez sur ESPACE pour commencer.""" %(targets[0],targets[1],detect,falseKey)
globInstr = """Maintenant, si la GRANDE est un %s ou un %s
N'importe la petite, appuyez sur %s.
Sinon, appuyez sur %s.\n
Appuyez sur ESPACE pour commencer.""" %(targets[0],targets[1],detect,falseKey)
locInstr = """Maintenant, si les PETITES sont des %s ou des %s
N'importe la grande, appuyez sur %s.
Sinon, appuyez sur %s.\n
Appuyez sur ESPACE pour commencer.""" %(targets[0],targets[1],detect,falseKey)
inverseInstr = """Maintenant, si NI la grande, NI les petites sont des %s ou des %s
Appuyez sur %s.
Sinon, NE RIEN FAIRE.\n
Appuyez sur ESPACE pour commencer.""" %(targets[0],targets[1],detect)

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

def instrTrial(Instructions,block_name):
	trial_name = xpy.design.Trial()
	stim = xpy.stimuli.TextBox(Instructions,(750,300),(0,-100))
	stim.preload()
	trial_name.add_stimulus(stim)
	block_name.add_trial(trial_name)

def mkTrial(trial_name, block, bName):
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
	trial_name.set_factor(name = "Targets", value = ''.join(targets))
	trial_name.set_factor(name = "Local", value = loc)
	trial_name.set_factor(name = "repCorr", value = getResponse(bName,glob,loc))
	block.add_trial(trial_name)

def getResponse(block,glob,loc):
	rep = repKeys[falseKey][1]
	if block == 'globLoc':
		if glob in targets or loc in targets:
			rep = repKeys[detect][1]
	elif block == 'glob':
		if glob in targets:
			rep = repKeys[detect][1]
	elif block == 'loc':
		if loc in targets:
			rep = repKeys[detect][1]
	elif block == 'inverse':
		if glob not in targets and loc not in targets:
			rep = repKeys[detect][1]
		else:
			rep = 'None'
	return rep

def addBlock(block):
	bName = block
	block = xpy.design.Block(name = block)
	trials = xpy.design.randomize.make_multiplied_shuffled_list(trial_types,n_scrambles)
	for trial in trials:
		mkTrial(trial,block,bName)
	exp.add_block(block)
	
def presentInstr(block_start,block_stop):
	for block in exp.blocks[block_start:block_stop]:
		for trial in block.trials:
			trial.stimuli[0].present(clear = True, update = True)
			exp.keyboard.wait(xpy.misc.constants.K_SPACE)

def presentBlock(block_start,block_stop):
	for block in exp.blocks[block_start:block_stop]:
		cross.present()
		for trial in block.trials:
			cross.present(clear = True, update = True)
			exp.clock.wait(rnd.randint(500,1000))
			trial.stimuli[0].present(clear = True, update= True)
			exp.clock.wait(250)
			blank.present(clear = True, update= True)
			key, rt = exp.keyboard.wait([xpy.misc.constants.K_f,
												xpy.misc.constants.K_j]
										,duration = 750)
			exp.data.add([block.name, trial.id, trial.get_factor("Type"), 
					trial.get_factor("Global"), trial.get_factor("Local"),
					trial.get_factor("Targets"),trial.get_factor("repCorr"),
					key, rt])
			blank.present(clear = True, update= False)
			exp.clock.wait(500)
	
cross = xpy.stimuli.FixCross((25,25),(0,0),4)
cross.preload()

blank = xpy.stimuli.BlankScreen()
blank.preload()

introGlobLoc = xpy.design.Block(name = "introGlobLoc")
instrTrial(globLocInstr,introGlobLoc)
exp.add_block(introGlobLoc)

addBlock(blocks[0])

introGlob = xpy.design.Block(name = "introGlob")
instrTrial(globInstr,introGlob)
exp.add_block(introGlob)

addBlock(blocks[1])

introLoc = xpy.design.Block(name = "introLoc")
instrTrial(locInstr,introLoc)
exp.add_block(introLoc)

addBlock(blocks[2])

introInverse = xpy.design.Block(name = "introInverse")
instrTrial(inverseInstr,introInverse)
exp.add_block(introInverse)

addBlock(blocks[3])

exp.data_variable_names = ["Block", "Trial", "Type", "Global", "Local","Targets","repCorr", "Key", "RT"]

xpy.control.start(skip_ready_screen = True)
blNum = 0
presentInstr(blNum,blNum + 1)
blNum += 1
presentBlock(blNum,blNum + 1)
blNum += 1

presentInstr(blNum,blNum + 1)
blNum += 1
presentBlock(blNum,blNum + 1)
blNum += 1

presentInstr(blNum,blNum + 1)
blNum += 1
presentBlock(blNum,blNum + 1)
blNum += 1

presentInstr(blNum,blNum + 1)
blNum += 1
presentBlock(blNum,blNum + 1)
blNum += 1

xpy.control.end()