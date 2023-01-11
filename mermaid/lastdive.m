function [errors, outfile] = lastdive(servdir, procdir)
% [errors, outfile] = LASTDIVE(servdir, procdir)
%
% Returns MERMAID serial numbers that include errors in the *.out files
% associated with the last dive, and also writes the contents of the *.out file
% associated with the last dive for each to:
% $MERMAID/processed/lastdive.txt, and
% $MERMAID/processed/lastdive_error.txt
%
% Input:
% servdir      MERMAID server directory (def: $MERMAID/server)
% procdir      MERMAID processed directory (def: $MERMAID/processed)
%
% Output:
% errors       List of MERMAID serial numbers which have error in .out file,
%                  associated with the last dive
% outfile      The contents of each *.out file corresponding to the last dive
%                  (fields are kstnm, e.g., "P0006", not OSEAN '452.020-P-16')
% *N/A*        Writes lastdive.txt and lastdive_error.txt to 'procdir'
%
% Note that the same command file is sent multiple times while at the surface,
% meaning that there may be an error in the outfile associated with the last
% surfacing despite the command file being successfully transmitted at another
% attempt (e.g., 15 minutes later). For example, during this surfacing the
% command file was successfully transferred at the first attempt.
%
%     {'***20210428-06h34mn58: sending cmd from 452.020-P-21.cmd'    }
%     {'Tx: "$log 0*74"'                                             }
%     {'Rx: "log 0"'                                                 }
%     {'Tx: "$buoy default*4A"'                                      }
%     {'Rx: "buoy default 0"'                                        }
%     {'Tx: "$buoy bypass 20000 120000*1A"'                          }
%     {'Rx: "buoy bypass 20000ms 120000ms (10000ms 120000ms stored)"'}
%     {'Tx: "$stage del*29"'                                         }
%     {'Rx: "stage del 2"'                                           }
%     {'Tx: "$stage 1000dbar (50dbar) 670mn (670mn)*60"'             }
%     {'Rx: "stage 1"'                                               }
%     {'Tx: "$stage 1000dbar (50dbar) 11630mn (12300mn)*65"'         }
%     {'Rx: "stage 2"'                                               }
%     {'Tx: "$stage store*3B"'                                       }
%     {'Rx: "stage store 48"'                                        }
%     {'Tx: "$mermaid UPLOAD_MAX:150*5D"'                            }
%     {'*** file 452.020-P-21.cmd content sent'                      }
%     {'*** Clear request commands ***'                              }
%     {0×0 char                                                      }
%     {'***20210428-06h45mn12: sending cmd from 452.020-P-21.cmd'    }
%     {'Tx: "$log 0*74"'                                             }
%     {'Rx: "log 0"'                                                 }
%     {'Tx: "$buoy default*4A"'                                      }
%     {'Rx: "buoy default 0"'                                        }
%     {'Tx: "$buoy bypass 20000 120000*1A"'                          }
%     {'Rx: "buoy bypass 20000ms 120000ms (10000ms 120000ms stored)"'}
%     {'Tx: "$stage del*29"'                                         }
%     {'Rx: "stage del 2"'                                           }
%     {'Tx: "$stage 1000dbar (50dbar) 670mn (670mn)*60"'             }
%     {'Rx: "stage 1"'                                               }
%     {'Tx: "$stage 1000dbar (50dbar) 11630mn (12300mn)*65"'         }
%     {'Rx: error code X1'                                           }
%     {'### cmd error 1'                                             }
%     {'*** try 1/3 failed for file 452.020-P-21.cmd'                }
%     {'Tx: "$log 0*74"'                                             }
%     {'Rx: error code X3'                                           }
%     {'### cmd error 3'                                             }
%     {'*** try 2/3 failed for file 452.020-P-21.cmd'                }
%     {'Tx: "$log 0*74"'                                             }
%     {'Rx: "log 0"'                                                 }
%     {'Tx: "$buoy default*4A"'                                      }
%     {'Rx: "log 0"'                                                 }
%     {'Rx: csum mismatch 74 instead of 4A'                          }
%     {'### cmd error 2'                                             }
%     {'*** try 3/3 failed for file 452.020-P-21.cmd'                }
%     {'*** too many errors, skipping file 452.020-P-21.cmd'         }
%     {0×0 char                                                      }
%
% Author: Joel D. Simon
% Contact: jdsimon@alumni.princeton.edu | joeldsimon@gmail.com
% Last modified: 10-Jan-2023, Version 9.3.0.948333 (R2017b) Update 9 on MACI64

% Defaults.
defval('servdir', fullfile(getenv('MERMAID'), 'server'))
defval('procdir', fullfile(getenv('MERMAID'), 'processed'))

% Collect all MERMAID *.out files using hyphens to skip nohup.out
out = globglob(servdir, '*-*-*.out');

% Write file of last dives for each float.
f = fullfile(procdir, 'lastdive.txt');
writeaccess('unlock', f, false)
fid = fopen(f, 'w');

f_error = fullfile(procdir, 'lastdive_error.txt');
writeaccess('unlock', f_error, false)
fid_error = fopen(f_error, 'w');
errors = {};
error_index = 0;

% Loop over all floats and parse just last dive contents from *.out.
for i = 1:length(out)
    % Read entire *.out file for this float.
    tx = readtext(out{i});

    % Chop ".out" off of filename to get MERMAID serial number.
    [~, serial_number] = fileparts(out{i});

    % Find all occurrences of "sending cmd...", which specifies new transmission.
    [cmd_index, cmd_datestr] = cellstrfind(tx, sprintf('sending cmd from %s.cmd', serial_number));

    % Find index corresponding to first command of last (most recent) dive.
    % Dives are defined by gaps greater than 24 hours between commands.
    date_strs = cellfun(@(xx) xx(4:11), cmd_datestr, 'UniformOutput', false);
    date_times = datetime(date_strs, 'Format', 'uuuuMMdd', 'TimeZone', 'UTC');
    dive_idx = days(diff(date_times)) > 1;
    last_dive = max(find(dive_idx)) + 1;  % it's a `diff` index, so add 1

    % Inspect text in *.out file corresponding to data since the last dive.
    dive_block = tx(cmd_index(last_dive):length(tx));
    contains_error = ~isempty(cellstrfind(dive_block, 'error'));
    if contains_error
        fprintf('WARNING: %s last dive contains error\n', serial_number)

    end

    % Write data.
    writeblock(fid, i, dive_block, serial_number, contains_error)
    if contains_error
        error_index = error_index + 1;
        errors{error_index} = serial_number;
        writeblock(fid_error, error_index, dive_block, serial_number, true)

    end

    % Collect output in struct
    % Convert OSEAN's naming convention to FDSN standards
    % 452.020-P-08 -> kinst = '452.020', kstnm = 'P0008'
    kstnm = osean2fdsn(serial_number);
    outfile.(kstnm) = dive_block;

end

% Close and restrict write access to files.
fclose(fid);
writeaccess('lock', f, false)
fclose(fid_error);
writeaccess('lock', f_error, false)

% Print output files.
fprintf('Wrote: %s\n', f)
fprintf('Wrote: %s\n', f_error)

%%______________________________________________________________________________________%%

function writeblock(fid, indexer, dive_block, serial_number, contains_error)
% Subfunction to write last dive blocks.

% Adapt header line if dive contains an error.
if ~contains_error
    header_line = sprintf('%s\n\n', serial_number);

else
    header_line = sprintf('!! ERROR -- %s -- ERROR !!\n\n', serial_number);

end

% Block separator, if not on first block.
if indexer ~= 1
    fprintf(fid, '%s\n', repmat('-', 50, 1));

end

% Write dive block.
fprintf(fid, '%s', header_line);
fprintf(fid, '%s\n', dive_block{:});
