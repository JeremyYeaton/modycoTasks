dir = 'C:\Users\AdminS2CH\Desktop\Experiments\modycoTasks\temp\videos\';
screenid = max(Screen('Screens'));
windowrect = [];
% vids = {'4c1','4C2'};
vids = {'consigne1','consigne 2'};
settingsSLpresent; % Load all the settings from the file
%%
% Open 'windowrect' sized window on screen, with black [0] background color:
win = Screen('OpenWindow', screenid, 0, windowrect);
AssertOpenGL;
for Idx = 1:length(vids)
    moviename = [dir vids{Idx} '.mp4'];
    if IsWin && ~IsOctave && psychusejava('jvm')
        fprintf('Running on Matlab for Microsoft Windows, with JVM enabled!\n');
        fprintf('This may crash. See ''help GStreamer'' for problem and workaround.\n');
        warning('Running on Matlab for Microsoft Windows, with JVM enabled!');
    end
    % Wait until user releases keys on keyboard:
    KbReleaseWait;
    try
        % Open movie file:
        movie = Screen('OpenMovie', win, moviename);

        % Start playback engine:
        Screen('PlayMovie', movie, 1);

        % Playback loop: Runs until end of movie or keypress:
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

        % Stop playback:
        Screen('PlayMovie', movie, 0);

        % Close movie:
        Screen('CloseMovie', movie);
    catch %#ok<CTCH>
        sca;
        psychrethrow(psychlasterror);
    end
end
% Close Screen, we're done:
sca;
