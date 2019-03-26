import expyriment as xpy

xpy.control.set_develop_mode(True)
"""Name your experiment"""
exp = xpy.design.Experiment(name="Simon Task")
xpy.control.initialize(exp)

"""Name of your stimuli blocks."""
block_names = ['one']
# ,'two','three','four']
"""Number of times you want to have each of the four types per scrambled block"""
n_scrambles = 1

"""Create your blocks of stimuli. This will take the list GM, GN, RM, RN and multiply it by however many trials x 4 that you want per block.
Then, using the trial builders, creates a trial corresponding to whichever item it gets from the list.
It then adds all those blocks to your experiment."""
def create_blocks(block_names):
	for block in block_names:
		block = xpy.design.Block(name = block)
		trials = xpy.design.randomize.make_multiplied_shuffled_list(trial_types,n_scrambles)
		for trial in trials:
			trial_(trial,block)
		exp.add_block(block)

def instr_trial(Instructions,trial_name,block_name):
	trial_name = xpy.design.Trial()
	stim = xpy.stimuli.TextBox(Instructions,(750,300),(0,-100))
	stim.preload()
	trial_name.add_stimulus(stim)
	block_name.add_trial(trial_name)

def present_instr(block_start,block_stop):
	for block in exp.blocks[block_start:block_stop]:
		for trial in block.trials:
			trial.stimuli[0].present(clear = True, update = True)
			exp.keyboard.wait(xpy.misc.constants.K_RETURN)

"""Prepare your trial types: 
GM = Green match, that is green on the right side. 
GN = Green non-match, that is green on the left side. 
The reverse is true for the red ones below."""
trial_types = ["GM","RM","GN","RN"]
class trial_(xpy.design.Trial):
	def __init__(self,trial_name,block_name):
		stim = xpy.stimuli.FixCross((25,25),(0,0),4)
		t_name = trial_name
		trial_name = xpy.design.Trial()
		if t_name == "GM":
			stim = xpy.stimuli.Circle(128,xpy.misc.constants.C_GREEN,0,(250,0))
		elif t_name == "GN":
			stim = xpy.stimuli.Circle(128,xpy.misc.constants.C_GREEN,0,(-250,0))
		elif t_name == "RM":
			stim = xpy.stimuli.Circle(128,xpy.misc.constants.C_RED,0,(-250,0))
		elif t_name == "RN":
			stim = xpy.stimuli.Circle(128,xpy.misc.constants.C_RED,0,(250,0))
		stim.preload()
		trial_name.add_stimulus(stim)
		trial_name.set_factor(name = "position", value = t_name)
		block_name.add_trial(trial_name)

"""Preparing the instructions and adding them as blocks to the experiment."""
intro = xpy.design.Block(name = "Intro")
instr_trial("""You will see a series of circles on the screen.\n\n
If the circle is GREEN, press the RIGHT key. If the circle is RED, press the LEFT key.\n\n
Press ENTER to continue.""","instructions1",intro)
instr_trial("""Let's practice! We'll have 4 practice trials, and then the Experiment will begin.\n\n
Press ENTER to continue.""","instructions2",intro)
exp.add_block(intro)

"""Preparing the practice trials and adding them to the experiment. This will have one trial of each type in the practice block."""
practice = xpy.design.Block(name = "Practice")
for t in trial_types:
	trial_(t,practice)
exp.add_block(practice)

failed_practice = xpy.design.Block(name = "Failed Practice")
instr_trial("""Not quite. Remember, it's RIGHT for GREEN, and LEFT for RED.\n
Now let's try those practice trials again.\n\n
Press ENTER to continue.""","instructions4",failed_practice)
exp.add_block(failed_practice)

sendoff = xpy.design.Block(name = "sendoff")
instr_trial("""Great job!\n\nNow press ENTER to start the experiment!""","instructions3",sendoff)
exp.add_block(sendoff)

create_blocks(block_names)

thank_you = xpy.design.Block(name = "Thank you")
instr_trial("""That's it! Thank you for participating in our study.\n\n Press ENTER to finish.""","thanks",thank_you)
exp.add_block(thank_you)

cross = xpy.stimuli.FixCross((25,25),(0,0),4)
cross.preload()

exp.data_variable_names = ["Block", "Trial", "Type","Key", "RT"]

xpy.control.start(skip_ready_screen = True)
ready = False
present_instr(0,1)

while ready == False:
	keys = []
	for block in exp.blocks[1:2]:
		for trial in block.trials:
			cross.present()
			exp.clock.wait(1000)
			cross.present(update = False)
			trial.stimuli[0].present(clear = False, update = True)
			key, rt = exp.keyboard.wait([xpy.misc.constants.K_LEFT,
	                                     xpy.misc.constants.K_RIGHT])
			keys.append(key)
			exp.data.add([block.name, trial.id, trial.get_factor("position"),key, rt])
	if keys == [275,276,275,276]:
		ready = True
	else:
		present_instr(2,3)
present_instr(3,4)

for block in exp.blocks[4:len(exp.blocks)-1]:
	for trial in block.trials:
		cross.present()
		exp.clock.wait(1000)
		cross.present(update = False)
		trial.stimuli[0].present(clear = False, update= True)
		key, rt = exp.keyboard.wait([xpy.misc.constants.K_LEFT,
                                     xpy.misc.constants.K_RIGHT])
		exp.data.add([block.name, trial.id, trial.get_factor("position"),key, rt])

present_instr(len(exp.blocks)-1,len(exp.blocks))
xpy.control.end()