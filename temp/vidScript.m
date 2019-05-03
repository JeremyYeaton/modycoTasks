root = 'C:\Users\AdminS2CH\Desktop\Experiments\modycoTasks\temp\videos\';
moviename = [root 'Consigne 2.mp4'];

Screen('Preference', 'SkipSyncTests', 0); % JY added

windowrect = [0 0 200 200];

screenid = max(Screen('Screens'));
%%
% Open 'windowrect' sized window on screen, with black [0] background color:
win = Screen('OpenWindow', screenid, 0, windowrect);

% Open movie file:
movie = Screen('OpenMovie', win, moviename);

% Start playback engine:
Screen('PlayMovie', movie, 1);

while ~KbCheck
    % Wait for next movie frame, retrieve texture handle to it
    tex = Screen('GetMovieImage', win, movie);

    % Valid texture returned? A negative value means end of movie reached:
    if tex<=0
        % We're done, break out of loop:
        break;
    end

    % Draw the new texture immediately to screen:
    Screen('DrawTexture', win, tex);

    % Update display:
    Screen('Flip', win);

    % Release texture:
    Screen('Close', tex);
end

% pause(10)

% Stop playback:
Screen('PlayMovie', movie, 0);

% Close movie:
Screen('CloseMovie', movie);

sca;
psychrethrow(psychlasterror);