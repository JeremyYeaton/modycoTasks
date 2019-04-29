# -*- coding: utf-8 -*-
'''
Modified Navon visual task
Author: Jeremy Yeaton
24 March 2019
'''

import expyriment as xpy, random as rnd, copy

subNum = int(input("Subject number: "))

#xpy.control.set_develop_mode(True)
exp = xpy.design.Experiment(name="Navon")
xpy.control.initialize(exp)


n_scrambles = 1

'''
implement practice
discuss time in instructions
'''
expBlockNames = ['gbLc','glob','loca']
globalLetters = ['O','S','H','L','A']
localLetters = ['O','S','H','L','A']

repKeys = {'F':[xpy.misc.constants.K_f,102],
		   'J':[xpy.misc.constants.K_j,106]}

if subNum % 2 == 0:
	detect = 'F'
	falseKey = 'J'
else:
	detect = 'J'
	falseKey = 'F'

targets = rnd.choices(globalLetters,k=3,replace=False)

trial_types = []
for globLet in globalLetters:
	for locLet in localLetters:
		trial_types.append(''.join([globLet,locLet]))
		
globLocInstr1 = """Tu vas voir apparaitre sur l’écran une lettre, composée d’autres lettres. 
Ces lettres peuvent être identiques ou différentes. 
Tu devras indiquer si la lettre EST ou CONTIENT les lettres %s ou %s.\n
Appuie sur ESPACE pour continuer."""%(targets[0],targets[1])
globLocInstr2 = """Si elle EST ou CONTIENT un %s ou un %s, appuie sur %s, 
sinon appuie sur %s.
Par exemple, si un grand %s apparait, ou un grand %s composé des petits %s, tu dois appuyer sur %s.
Essaie d’être aussi rapide et correcte que possible !\n
Appuie sur ESPACE pour essayer.""" %(targets[0],targets[1],detect,falseKey,targets[0],targets[2],targets[1],detect)

globInstr1 = """Maintenant, un exercice du même genre mais cette fois-ci, 
il faudra juste indiquer si la lettre EST un %s ou un %s, 
quelles que soient les lettres qui la composent.\n
Appuie sur ESPACE pour continuer."""%(targets[0],targets[1])
globInstr2 = """Si elle EST un %s ou un %s, appuie sur %s, 
sinon appuie sur %s.
Par exemple, si un grand %s apparait, tu dois toujours appuyer sur %s.
Essaie d’être aussi rapide et correcte que possible !\n
Appuie sur ESPACE pour essayer."""%(targets[0],targets[1],detect,falseKey,targets[0],detect)

locInstr1 = """Et maintenant, il faudra indiquer si les COMPOSANTS de la lettre 
(qu’elle que soit cette lettre) sont des %s ou des %s.\n
Appuie sur ESPACE pour continuer."""%(targets[0],targets[1]) 
locInstr2 = """Si les COMPOSANTS (petites lettres) sont des %s ou des %s, appuie sur %s, 
sinon appuie sur %s. 
Essaie d’être aussi rapide et correcte que possible !\n
Appuie sur ESPACE pour essayer."""%(targets[0],targets[1],detect,falseKey)

sendOff = """Tres bien!\n\n 
Appuyez sur ESPACE pour commencer."""

retryTxt = """Pas exactement. Rappelez:
STUFF \n\n 
Appuyez sur ESPACE pour ressayer."""

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
	stim = xpy.stimuli.TextBox(Instructions,(750,500),(0,-100),text_size = 40)
	stim.preload()
	trial_name.add_stimulus(stim)
	block_name.add_trial(trial_name)

def mkTrial(trial_name, block):
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
	trial_name.set_factor(name = "repCorr", value = getResponse(block.name[0:4],glob,loc))
	block.add_trial(trial_name)

def getResponse(block,glob,loc):
	rep = repKeys[falseKey][1]
	if block == 'gbLc':
		if glob in targets or loc in targets:
			rep = repKeys[detect][1]
	elif block == 'glob':
		if glob in targets:
			rep = repKeys[detect][1]
	elif block == 'loca':
		if loc in targets:
			rep = repKeys[detect][1]
	elif block == 'nvrs':
		if glob not in targets and loc not in targets:
			rep = repKeys[detect][1]
		else:
			rep = 'None'
	return rep

def addBlock(block, prac = int):
	blockNum = block
	if prac == True:
		trials = xpy.design.randomize.make_multiplied_shuffled_list(trial_types,1)
		trials = rnd.choices(trials,k=5,replace=False)
		block = ''.join([str(blockNum),' Practice'])
	else:
		trials = xpy.design.randomize.make_multiplied_shuffled_list(trial_types,n_scrambles)
	block = xpy.design.Block(name = expBlockNames[blockNum])
	for trial in trials:
		mkTrial(trial,block)
	exp.add_block(block)
	
def presentInstr(blockNum):
	for block in exp.blocks[blockNum:blockNum + 1]:
		for trial in block.trials:
			trial.stimuli[0].present(clear = True, update = True)
			exp.keyboard.wait(xpy.misc.constants.K_SPACE)

def presentBlock(blockNum, prac = int):
	ready = False
	while ready == False:
		err = 0
		for block in exp.blocks[blockNum:blockNum + 1]:
			cross.present()
			for trial in block.trials:
				cross.present(clear = True, update = True)
				exp.clock.wait(rnd.randint(500,1000))
				trial.stimuli[0].present(clear = True, update= True)
				exp.clock.wait(250)
#				blank.present(clear = True, update= True)
				key, rt = exp.keyboard.wait([xpy.misc.constants.K_f,
													xpy.misc.constants.K_j]
											,duration = 1500)
				exp.data.add([block.name, trial.id, trial.get_factor("Type"), 
						trial.get_factor("Global"), trial.get_factor("Local"),
						trial.get_factor("Targets"),trial.get_factor("repCorr"),
						key, rt])
				blank.present(clear = True, update= False)
				exp.clock.wait(500)
				if key != trial.get_factor("repCorr") and prac == 1:
					err += 1
					break
			if prac != 1:
				ready = True
			elif err == 0 and prac == 1:
				ready = True
				sendoff.present()
				exp.keyboard.wait(xpy.misc.constants.K_SPACE)
			else:
				retry.present()
				exp.keyboard.wait(xpy.misc.constants.K_SPACE)

sendoff = xpy.stimuli.TextBox(sendOff,(750,300),(0,-100))
sendoff.preload()
retry = xpy.stimuli.TextBox(retryTxt,(750,300),(0,-100))
retry.preload()
	
cross = xpy.stimuli.FixCross((25,25),(0,0),4)
cross.preload()

blank = xpy.stimuli.BlankScreen()
blank.preload()

blockNames = ["introGlobLoc",0,"introGlob",1,"introLoc",2]
instrDict = {"introGlobLoc":[globLocInstr1,globLocInstr2],
			"introGlob":[globInstr1,globInstr2],
			"introLoc": [locInstr1,locInstr2]}

for blck in blockNames:
	if type(blck) == str:
		Block = xpy.design.Block(name = blck)
		for instr in instrDict[blck]:
			instrTrial(instr,Block)
		exp.add_block(Block)
	elif type(blck) == int:
		addBlock(blck,prac = 1)
		addBlock(blck)

exp.data_variable_names = ["Block", "Trial", "Type", "Global", "Local","Targets","repCorr", "Key", "RT"]

xpy.control.start(skip_ready_screen = True,subject_id = subNum)
blNum = 0
for i in range(0,3):
	presentInstr(blNum)
	blNum += 1
	presentBlock(blNum,prac = 1)
	blNum += 1
	presentBlock(blNum)
	blNum += 1

xpy.control.end(goodbye_text="Merci pour votre participation!")