function isupdated = update_nearby_cppt_tauptimes
% isupdated = UPDATE_NEARBY_CPPT_TAUPTIMES
%
% Runs updatetauptimes.m on all nearby and CPPT .evt files assuming JDS'
% system defaults.
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 02-Feb-2021, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

mer_dir = fullfile(getenv('MERMAID'), 'events');
nearby_dir =  skipdotdir(dir(fullfile(mer_dir, 'nearbystations', 'evt')));
cppt_dir =  skipdotdir(dir(fullfile(mer_dir, 'cpptstations', 'evt')));

nearby_id = {nearby_dir.name};
cppt_id = {cppt_dir.name};

ct = 0
for i = 1:length(nearby_id)
    [sacfile, sacfile_u] = getnearbysac(nearby_id{i}, 'vel');
    sacfile = [sacfile ; sacfile_u];

    [EQ, EQ_u, evtfile, evtfile_u] = getnearbyevt(nearby_id{i});
    EQ = [EQ ; EQ_u];
    evtfile = [evtfile ; evtfile_u];

    for j = 1:length(sacfile)
        [~,h] = readsac(sacfile{j});

        if ~isempty(EQ{j})
            ct = ct + 1;
            isupdated(ct) = updatetauptimes(sacfile{j}, evtfile{j});

            % if isupdated
            %     fprintf('Yes: %i\n', h.NZMSEC)

            % else
            %     fprintf('No: i\n', h.NZMSEC)
            %     if h.NZMSEC < 100 & h.NZMSEC ~= 0
            %         error(sprintf('%s', sacfile{j}))

            %     end
            % end
        end
    end
end

for i = 1:length(cppt_id)
    sacfile = getcpptsac(cppt_id{i}, 'vel');

    [EQ, evtfile] = getcpptevt(cppt_id{i});

    for j = 1:length(sacfile)
        [~,h] = readsac(sacfile{j});

        if ~isempty(EQ{j})
            ct = ct + 1;
            isupdated(ct) = updatetauptimes(sacfile{j}, evtfile{j});

            % if isupdated
            %     fprintf('Yes: %i\n', h.NZMSEC)

            % else
            %     fprintf('No: %i\n', h.NZMSEC)
            %     if h.NZMSEC < 100 & h.NZMSEC ~= 0
            %         error(sprintf('%s', sacfile{j}))

            %     end
            % end
        end
    end
end
