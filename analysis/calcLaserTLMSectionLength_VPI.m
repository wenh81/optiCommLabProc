% Calc LaserTLM section length
GroupIndex             = 3.7;
c                      = 299792458;
v_g                    = c/GroupIndex;
BitRateDefault         = 10e9;
SampleRateDefault      = 8*BitRateDefault;
SampleModeBandWidth    = 8*SampleRateDefault;
SectionLength          = v_g/SampleModeBandWidth;

SectionNum             = 1; % fixed to 1 in laserTML module
Length                 = SectionNum * SectionLength


