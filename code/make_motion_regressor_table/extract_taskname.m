function taskname = extract_taskname(str)

    switch true

        case contains(str, 'REST1')
             if contains(str,'_LR'), taskname = 'REST1_LR'; else taskname = 'REST1_RL'; end;

        case contains(str, 'REST2')
             if contains(str,'_LR'), taskname = 'REST2_LR'; else taskname = 'REST2_RL'; end;

        case contains(str, 'EMOTION')
             if contains(str,'_LR'), taskname = 'EMOTION_LR'; else taskname = 'EMOTION_RL'; end;

        case contains(str, 'GAMBLING')
             if contains(str,'_LR'), taskname = 'GAMBLING_LR'; else taskname = 'GAMBLING_RL'; end;

        case contains(str, 'LANGUAGE')
             if contains(str,'_LR'), taskname = 'LANGUAGE_LR'; else taskname = 'LANGUAGE_RL'; end;

        case contains(str, 'MOTOR')
             if contains(str,'_LR'), taskname = 'MOTOR_LR'; else taskname = 'MOTOR_RL'; end;

        case contains(str, 'RELATIONAL')
             if contains(str,'_LR'), taskname = 'RELATIONAL_LR'; else taskname = 'RELATIONAL_RL'; end;

        case contains(str, 'SOCIAL')
             if contains(str,'_LR'), taskname = 'SOCIAL_LR'; else taskname = 'SOCIAL_RL'; end;

        case contains(str, 'WM')
             if contains(str,'_LR'), taskname = 'WM_LR'; else taskname = 'WM_RL'; end;

        otherwise
             disp('Could not find task name in the provided string...');
             taskname = [];
    end
end
