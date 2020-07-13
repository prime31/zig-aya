pub const SOLOUD_AUTO = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_AUTO);
pub const SOLOUD_SDL1 = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_SDL1);
pub const SOLOUD_SDL2 = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_SDL2);
pub const SOLOUD_PORTAUDIO = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_PORTAUDIO);
pub const SOLOUD_WINMM = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WINMM);
pub const SOLOUD_XAUDIO2 = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_XAUDIO2);
pub const SOLOUD_WASAPI = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WASAPI);
pub const SOLOUD_ALSA = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_ALSA);
pub const SOLOUD_JACK = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_JACK);
pub const SOLOUD_OSS = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_OSS);
pub const SOLOUD_OPENAL = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_OPENAL);
pub const SOLOUD_COREAUDIO = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_COREAUDIO);
pub const SOLOUD_OPENSLES = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_OPENSLES);
pub const SOLOUD_VITA_HOMEBREW = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_VITA_HOMEBREW);
pub const SOLOUD_MINIAUDIO = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_MINIAUDIO);
pub const SOLOUD_NOSOUND = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_NOSOUND);
pub const SOLOUD_NULLDRIVER = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_NULLDRIVER);
pub const SOLOUD_BACKEND_MAX = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_BACKEND_MAX);
pub const SOLOUD_CLIP_ROUNDOFF = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_CLIP_ROUNDOFF);
pub const SOLOUD_ENABLE_VISUALIZATION = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_ENABLE_VISUALIZATION);
pub const SOLOUD_LEFT_HANDED_3D = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_LEFT_HANDED_3D);
pub const SOLOUD_NO_FPU_REGISTER_CHANGE = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_NO_FPU_REGISTER_CHANGE);
pub const SOLOUD_WAVE_SQUARE = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WAVE_SQUARE);
pub const SOLOUD_WAVE_SAW = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WAVE_SAW);
pub const SOLOUD_WAVE_SIN = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WAVE_SIN);
pub const SOLOUD_WAVE_TRIANGLE = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WAVE_TRIANGLE);
pub const SOLOUD_WAVE_BOUNCE = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WAVE_BOUNCE);
pub const SOLOUD_WAVE_JAWS = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WAVE_JAWS);
pub const SOLOUD_WAVE_HUMPS = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WAVE_HUMPS);
pub const SOLOUD_WAVE_FSQUARE = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WAVE_FSQUARE);
pub const SOLOUD_WAVE_FSAW = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_WAVE_FSAW);
pub const SOLOUD_RESAMPLER_POINT = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_RESAMPLER_POINT);
pub const SOLOUD_RESAMPLER_LINEAR = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_RESAMPLER_LINEAR);
pub const SOLOUD_RESAMPLER_CATMULLROM = @enumToInt(enum_SOLOUD_ENUMS.SOLOUD_RESAMPLER_CATMULLROM);
pub const BASSBOOSTFILTER_WET = @enumToInt(enum_SOLOUD_ENUMS.BASSBOOSTFILTER_WET);
pub const BASSBOOSTFILTER_BOOST = @enumToInt(enum_SOLOUD_ENUMS.BASSBOOSTFILTER_BOOST);
pub const BIQUADRESONANTFILTER_LOWPASS = @enumToInt(enum_SOLOUD_ENUMS.BIQUADRESONANTFILTER_LOWPASS);
pub const BIQUADRESONANTFILTER_HIGHPASS = @enumToInt(enum_SOLOUD_ENUMS.BIQUADRESONANTFILTER_HIGHPASS);
pub const BIQUADRESONANTFILTER_BANDPASS = @enumToInt(enum_SOLOUD_ENUMS.BIQUADRESONANTFILTER_BANDPASS);
pub const BIQUADRESONANTFILTER_WET = @enumToInt(enum_SOLOUD_ENUMS.BIQUADRESONANTFILTER_WET);
pub const BIQUADRESONANTFILTER_TYPE = @enumToInt(enum_SOLOUD_ENUMS.BIQUADRESONANTFILTER_TYPE);
pub const BIQUADRESONANTFILTER_FREQUENCY = @enumToInt(enum_SOLOUD_ENUMS.BIQUADRESONANTFILTER_FREQUENCY);
pub const BIQUADRESONANTFILTER_RESONANCE = @enumToInt(enum_SOLOUD_ENUMS.BIQUADRESONANTFILTER_RESONANCE);
pub const ECHOFILTER_WET = @enumToInt(enum_SOLOUD_ENUMS.ECHOFILTER_WET);
pub const ECHOFILTER_DELAY = @enumToInt(enum_SOLOUD_ENUMS.ECHOFILTER_DELAY);
pub const ECHOFILTER_DECAY = @enumToInt(enum_SOLOUD_ENUMS.ECHOFILTER_DECAY);
pub const ECHOFILTER_FILTER = @enumToInt(enum_SOLOUD_ENUMS.ECHOFILTER_FILTER);
pub const FLANGERFILTER_WET = @enumToInt(enum_SOLOUD_ENUMS.FLANGERFILTER_WET);
pub const FLANGERFILTER_DELAY = @enumToInt(enum_SOLOUD_ENUMS.FLANGERFILTER_DELAY);
pub const FLANGERFILTER_FREQ = @enumToInt(enum_SOLOUD_ENUMS.FLANGERFILTER_FREQ);
pub const FREEVERBFILTER_WET = @enumToInt(enum_SOLOUD_ENUMS.FREEVERBFILTER_WET);
pub const FREEVERBFILTER_FREEZE = @enumToInt(enum_SOLOUD_ENUMS.FREEVERBFILTER_FREEZE);
pub const FREEVERBFILTER_ROOMSIZE = @enumToInt(enum_SOLOUD_ENUMS.FREEVERBFILTER_ROOMSIZE);
pub const FREEVERBFILTER_DAMP = @enumToInt(enum_SOLOUD_ENUMS.FREEVERBFILTER_DAMP);
pub const FREEVERBFILTER_WIDTH = @enumToInt(enum_SOLOUD_ENUMS.FREEVERBFILTER_WIDTH);
pub const LOFIFILTER_WET = @enumToInt(enum_SOLOUD_ENUMS.LOFIFILTER_WET);
pub const LOFIFILTER_SAMPLERATE = @enumToInt(enum_SOLOUD_ENUMS.LOFIFILTER_SAMPLERATE);
pub const LOFIFILTER_BITDEPTH = @enumToInt(enum_SOLOUD_ENUMS.LOFIFILTER_BITDEPTH);
pub const NOISE_WHITE = @enumToInt(enum_SOLOUD_ENUMS.NOISE_WHITE);
pub const NOISE_PINK = @enumToInt(enum_SOLOUD_ENUMS.NOISE_PINK);
pub const NOISE_BROWNISH = @enumToInt(enum_SOLOUD_ENUMS.NOISE_BROWNISH);
pub const NOISE_BLUEISH = @enumToInt(enum_SOLOUD_ENUMS.NOISE_BLUEISH);
pub const ROBOTIZEFILTER_WET = @enumToInt(enum_SOLOUD_ENUMS.ROBOTIZEFILTER_WET);
pub const ROBOTIZEFILTER_FREQ = @enumToInt(enum_SOLOUD_ENUMS.ROBOTIZEFILTER_FREQ);
pub const ROBOTIZEFILTER_WAVE = @enumToInt(enum_SOLOUD_ENUMS.ROBOTIZEFILTER_WAVE);
pub const SFXR_COIN = @enumToInt(enum_SOLOUD_ENUMS.SFXR_COIN);
pub const SFXR_LASER = @enumToInt(enum_SOLOUD_ENUMS.SFXR_LASER);
pub const SFXR_EXPLOSION = @enumToInt(enum_SOLOUD_ENUMS.SFXR_EXPLOSION);
pub const SFXR_POWERUP = @enumToInt(enum_SOLOUD_ENUMS.SFXR_POWERUP);
pub const SFXR_HURT = @enumToInt(enum_SOLOUD_ENUMS.SFXR_HURT);
pub const SFXR_JUMP = @enumToInt(enum_SOLOUD_ENUMS.SFXR_JUMP);
pub const SFXR_BLIP = @enumToInt(enum_SOLOUD_ENUMS.SFXR_BLIP);
pub const SPEECH_KW_SAW = @enumToInt(enum_SOLOUD_ENUMS.SPEECH_KW_SAW);
pub const SPEECH_KW_TRIANGLE = @enumToInt(enum_SOLOUD_ENUMS.SPEECH_KW_TRIANGLE);
pub const SPEECH_KW_SIN = @enumToInt(enum_SOLOUD_ENUMS.SPEECH_KW_SIN);
pub const SPEECH_KW_SQUARE = @enumToInt(enum_SOLOUD_ENUMS.SPEECH_KW_SQUARE);
pub const SPEECH_KW_PULSE = @enumToInt(enum_SOLOUD_ENUMS.SPEECH_KW_PULSE);
pub const SPEECH_KW_NOISE = @enumToInt(enum_SOLOUD_ENUMS.SPEECH_KW_NOISE);
pub const SPEECH_KW_WARBLE = @enumToInt(enum_SOLOUD_ENUMS.SPEECH_KW_WARBLE);
pub const VIC_PAL = @enumToInt(enum_SOLOUD_ENUMS.VIC_PAL);
pub const VIC_NTSC = @enumToInt(enum_SOLOUD_ENUMS.VIC_NTSC);
pub const VIC_BASS = @enumToInt(enum_SOLOUD_ENUMS.VIC_BASS);
pub const VIC_ALTO = @enumToInt(enum_SOLOUD_ENUMS.VIC_ALTO);
pub const VIC_SOPRANO = @enumToInt(enum_SOLOUD_ENUMS.VIC_SOPRANO);
pub const VIC_NOISE = @enumToInt(enum_SOLOUD_ENUMS.VIC_NOISE);
pub const VIC_MAX_REGS = @enumToInt(enum_SOLOUD_ENUMS.VIC_MAX_REGS);
pub const WAVESHAPERFILTER_WET = @enumToInt(enum_SOLOUD_ENUMS.WAVESHAPERFILTER_WET);
pub const WAVESHAPERFILTER_AMOUNT = @enumToInt(enum_SOLOUD_ENUMS.WAVESHAPERFILTER_AMOUNT);
pub const enum_SOLOUD_ENUMS = extern enum(c_int) {
    SOLOUD_AUTO = 0,
    SOLOUD_SDL1 = 1,
    SOLOUD_SDL2 = 2,
    SOLOUD_PORTAUDIO = 3,
    SOLOUD_WINMM = 4,
    SOLOUD_XAUDIO2 = 5,
    SOLOUD_WASAPI = 6,
    SOLOUD_ALSA = 7,
    SOLOUD_JACK = 8,
    SOLOUD_OSS = 9,
    SOLOUD_OPENAL = 10,
    SOLOUD_COREAUDIO = 11,
    SOLOUD_OPENSLES = 12,
    SOLOUD_VITA_HOMEBREW = 13,
    SOLOUD_MINIAUDIO = 14,
    SOLOUD_NOSOUND = 15,
    SOLOUD_NULLDRIVER = 16,
    SOLOUD_BACKEND_MAX = 17,
    SOLOUD_CLIP_ROUNDOFF = 1,
    SOLOUD_ENABLE_VISUALIZATION = 2,
    SOLOUD_LEFT_HANDED_3D = 4,
    SOLOUD_NO_FPU_REGISTER_CHANGE = 8,
    SOLOUD_WAVE_SQUARE = 0,
    SOLOUD_WAVE_SAW = 1,
    SOLOUD_WAVE_SIN = 2,
    SOLOUD_WAVE_TRIANGLE = 3,
    SOLOUD_WAVE_BOUNCE = 4,
    SOLOUD_WAVE_JAWS = 5,
    SOLOUD_WAVE_HUMPS = 6,
    SOLOUD_WAVE_FSQUARE = 7,
    SOLOUD_WAVE_FSAW = 8,
    SOLOUD_RESAMPLER_POINT = 0,
    SOLOUD_RESAMPLER_LINEAR = 1,
    SOLOUD_RESAMPLER_CATMULLROM = 2,
    BASSBOOSTFILTER_WET = 0,
    BASSBOOSTFILTER_BOOST = 1,
    BIQUADRESONANTFILTER_LOWPASS = 0,
    BIQUADRESONANTFILTER_HIGHPASS = 1,
    BIQUADRESONANTFILTER_BANDPASS = 2,
    BIQUADRESONANTFILTER_WET = 0,
    BIQUADRESONANTFILTER_TYPE = 1,
    BIQUADRESONANTFILTER_FREQUENCY = 2,
    BIQUADRESONANTFILTER_RESONANCE = 3,
    ECHOFILTER_WET = 0,
    ECHOFILTER_DELAY = 1,
    ECHOFILTER_DECAY = 2,
    ECHOFILTER_FILTER = 3,
    FLANGERFILTER_WET = 0,
    FLANGERFILTER_DELAY = 1,
    FLANGERFILTER_FREQ = 2,
    FREEVERBFILTER_WET = 0,
    FREEVERBFILTER_FREEZE = 1,
    FREEVERBFILTER_ROOMSIZE = 2,
    FREEVERBFILTER_DAMP = 3,
    FREEVERBFILTER_WIDTH = 4,
    LOFIFILTER_WET = 0,
    LOFIFILTER_SAMPLERATE = 1,
    LOFIFILTER_BITDEPTH = 2,
    NOISE_WHITE = 0,
    NOISE_PINK = 1,
    NOISE_BROWNISH = 2,
    NOISE_BLUEISH = 3,
    ROBOTIZEFILTER_WET = 0,
    ROBOTIZEFILTER_FREQ = 1,
    ROBOTIZEFILTER_WAVE = 2,
    SFXR_COIN = 0,
    SFXR_LASER = 1,
    SFXR_EXPLOSION = 2,
    SFXR_POWERUP = 3,
    SFXR_HURT = 4,
    SFXR_JUMP = 5,
    SFXR_BLIP = 6,
    SPEECH_KW_SAW = 0,
    SPEECH_KW_TRIANGLE = 1,
    SPEECH_KW_SIN = 2,
    SPEECH_KW_SQUARE = 3,
    SPEECH_KW_PULSE = 4,
    SPEECH_KW_NOISE = 5,
    SPEECH_KW_WARBLE = 6,
    VIC_PAL = 0,
    VIC_NTSC = 1,
    VIC_BASS = 0,
    VIC_ALTO = 1,
    VIC_SOPRANO = 2,
    VIC_NOISE = 3,
    VIC_MAX_REGS = 4,
    WAVESHAPERFILTER_WET = 0,
    WAVESHAPERFILTER_AMOUNT = 1,
    _,
};
pub const AlignedFloatBuffer = ?*c_void;
pub const TinyAlignedFloatBuffer = ?*c_void;
pub const Soloud = ?*c_void;
pub const Ay = ?*c_void;
pub const AudioCollider = ?*c_void;
pub const AudioAttenuator = ?*c_void;
pub const AudioSource = ?*c_void;
pub const BassboostFilter = ?*c_void;
pub const BiquadResonantFilter = ?*c_void;
pub const Bus = ?*c_void;
pub const DCRemovalFilter = ?*c_void;
pub const EchoFilter = ?*c_void;
pub const Fader = ?*c_void;
pub const FFTFilter = ?*c_void;
pub const Filter = ?*c_void;
pub const FlangerFilter = ?*c_void;
pub const FreeverbFilter = ?*c_void;
pub const LofiFilter = ?*c_void;
pub const Monotone = ?*c_void;
pub const Noise = ?*c_void;
pub const Openmpt = ?*c_void;
pub const Queue = ?*c_void;
pub const RobotizeFilter = ?*c_void;
pub const Sfxr = ?*c_void;
pub const Speech = ?*c_void;
pub const TedSid = ?*c_void;
pub const Vic = ?*c_void;
pub const Vizsn = ?*c_void;
pub const Wav = ?*c_void;
pub const WaveShaperFilter = ?*c_void;
pub const WavStream = ?*c_void;
pub const File = ?*c_void;
pub extern fn Soloud_destroy(aSoloud: [*c]Soloud) void;
pub extern fn Soloud_create(...) [*c]Soloud;
pub extern fn Soloud_init(aSoloud: [*c]Soloud) c_int;
pub extern fn Soloud_initEx(aSoloud: [*c]Soloud, aFlags: c_uint, aBackend: c_uint, aSamplerate: c_uint, aBufferSize: c_uint, aChannels: c_uint) c_int;
pub extern fn Soloud_deinit(aSoloud: [*c]Soloud) void;
pub extern fn Soloud_getVersion(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_getErrorString(aSoloud: [*c]Soloud, aErrorCode: c_int) [*c]const u8;
pub extern fn Soloud_getBackendId(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_getBackendString(aSoloud: [*c]Soloud) [*c]const u8;
pub extern fn Soloud_getBackendChannels(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_getBackendSamplerate(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_getBackendBufferSize(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_setSpeakerPosition(aSoloud: [*c]Soloud, aChannel: c_uint, aX: f32, aY: f32, aZ: f32) c_int;
pub extern fn Soloud_getSpeakerPosition(aSoloud: [*c]Soloud, aChannel: c_uint, aX: [*c]f32, aY: [*c]f32, aZ: [*c]f32) c_int;
pub extern fn Soloud_play(aSoloud: [*c]Soloud, aSound: [*c]AudioSource) c_uint;
pub extern fn Soloud_playEx(aSoloud: [*c]Soloud, aSound: [*c]AudioSource, aVolume: f32, aPan: f32, aPaused: c_int, aBus: c_uint) c_uint;
pub extern fn Soloud_playClocked(aSoloud: [*c]Soloud, aSoundTime: f64, aSound: [*c]AudioSource) c_uint;
pub extern fn Soloud_playClockedEx(aSoloud: [*c]Soloud, aSoundTime: f64, aSound: [*c]AudioSource, aVolume: f32, aPan: f32, aBus: c_uint) c_uint;
pub extern fn Soloud_play3d(aSoloud: [*c]Soloud, aSound: [*c]AudioSource, aPosX: f32, aPosY: f32, aPosZ: f32) c_uint;
pub extern fn Soloud_play3dEx(aSoloud: [*c]Soloud, aSound: [*c]AudioSource, aPosX: f32, aPosY: f32, aPosZ: f32, aVelX: f32, aVelY: f32, aVelZ: f32, aVolume: f32, aPaused: c_int, aBus: c_uint) c_uint;
pub extern fn Soloud_play3dClocked(aSoloud: [*c]Soloud, aSoundTime: f64, aSound: [*c]AudioSource, aPosX: f32, aPosY: f32, aPosZ: f32) c_uint;
pub extern fn Soloud_play3dClockedEx(aSoloud: [*c]Soloud, aSoundTime: f64, aSound: [*c]AudioSource, aPosX: f32, aPosY: f32, aPosZ: f32, aVelX: f32, aVelY: f32, aVelZ: f32, aVolume: f32, aBus: c_uint) c_uint;
pub extern fn Soloud_playBackground(aSoloud: [*c]Soloud, aSound: [*c]AudioSource) c_uint;
pub extern fn Soloud_playBackgroundEx(aSoloud: [*c]Soloud, aSound: [*c]AudioSource, aVolume: f32, aPaused: c_int, aBus: c_uint) c_uint;
pub extern fn Soloud_seek(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aSeconds: f64) c_int;
pub extern fn Soloud_stop(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) void;
pub extern fn Soloud_stopAll(aSoloud: [*c]Soloud) void;
pub extern fn Soloud_stopAudioSource(aSoloud: [*c]Soloud, aSound: [*c]AudioSource) void;
pub extern fn Soloud_countAudioSource(aSoloud: [*c]Soloud, aSound: [*c]AudioSource) c_int;
pub extern fn Soloud_setFilterParameter(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aFilterId: c_uint, aAttributeId: c_uint, aValue: f32) void;
pub extern fn Soloud_getFilterParameter(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aFilterId: c_uint, aAttributeId: c_uint) f32;
pub extern fn Soloud_fadeFilterParameter(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aFilterId: c_uint, aAttributeId: c_uint, aTo: f32, aTime: f64) void;
pub extern fn Soloud_oscillateFilterParameter(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aFilterId: c_uint, aAttributeId: c_uint, aFrom: f32, aTo: f32, aTime: f64) void;
pub extern fn Soloud_getStreamTime(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) f64;
pub extern fn Soloud_getStreamPosition(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) f64;
pub extern fn Soloud_getPause(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) c_int;
pub extern fn Soloud_getVolume(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) f32;
pub extern fn Soloud_getOverallVolume(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) f32;
pub extern fn Soloud_getPan(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) f32;
pub extern fn Soloud_getSamplerate(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) f32;
pub extern fn Soloud_getProtectVoice(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) c_int;
pub extern fn Soloud_getActiveVoiceCount(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_getVoiceCount(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_isValidVoiceHandle(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) c_int;
pub extern fn Soloud_getRelativePlaySpeed(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) f32;
pub extern fn Soloud_getPostClipScaler(aSoloud: [*c]Soloud) f32;
pub extern fn Soloud_getMainResampler(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_getGlobalVolume(aSoloud: [*c]Soloud) f32;
pub extern fn Soloud_getMaxActiveVoiceCount(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_getLooping(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) c_int;
pub extern fn Soloud_getAutoStop(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) c_int;
pub extern fn Soloud_getLoopPoint(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) f64;
pub extern fn Soloud_setLoopPoint(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aLoopPoint: f64) void;
pub extern fn Soloud_setLooping(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aLooping: c_int) void;
pub extern fn Soloud_setAutoStop(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aAutoStop: c_int) void;
pub extern fn Soloud_setMaxActiveVoiceCount(aSoloud: [*c]Soloud, aVoiceCount: c_uint) c_int;
pub extern fn Soloud_setInaudibleBehavior(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aMustTick: c_int, aKill: c_int) void;
pub extern fn Soloud_setGlobalVolume(aSoloud: [*c]Soloud, aVolume: f32) void;
pub extern fn Soloud_setPostClipScaler(aSoloud: [*c]Soloud, aScaler: f32) void;
pub extern fn Soloud_setMainResampler(aSoloud: [*c]Soloud, aResampler: c_uint) void;
pub extern fn Soloud_setPause(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aPause: c_int) void;
pub extern fn Soloud_setPauseAll(aSoloud: [*c]Soloud, aPause: c_int) void;
pub extern fn Soloud_setRelativePlaySpeed(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aSpeed: f32) c_int;
pub extern fn Soloud_setProtectVoice(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aProtect: c_int) void;
pub extern fn Soloud_setSamplerate(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aSamplerate: f32) void;
pub extern fn Soloud_setPan(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aPan: f32) void;
pub extern fn Soloud_setPanAbsolute(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aLVolume: f32, aRVolume: f32) void;
pub extern fn Soloud_setChannelVolume(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aChannel: c_uint, aVolume: f32) void;
pub extern fn Soloud_setVolume(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aVolume: f32) void;
pub extern fn Soloud_setDelaySamples(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aSamples: c_uint) void;
pub extern fn Soloud_fadeVolume(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aTo: f32, aTime: f64) void;
pub extern fn Soloud_fadePan(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aTo: f32, aTime: f64) void;
pub extern fn Soloud_fadeRelativePlaySpeed(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aTo: f32, aTime: f64) void;
pub extern fn Soloud_fadeGlobalVolume(aSoloud: [*c]Soloud, aTo: f32, aTime: f64) void;
pub extern fn Soloud_schedulePause(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aTime: f64) void;
pub extern fn Soloud_scheduleStop(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aTime: f64) void;
pub extern fn Soloud_oscillateVolume(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aFrom: f32, aTo: f32, aTime: f64) void;
pub extern fn Soloud_oscillatePan(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aFrom: f32, aTo: f32, aTime: f64) void;
pub extern fn Soloud_oscillateRelativePlaySpeed(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aFrom: f32, aTo: f32, aTime: f64) void;
pub extern fn Soloud_oscillateGlobalVolume(aSoloud: [*c]Soloud, aFrom: f32, aTo: f32, aTime: f64) void;
pub extern fn Soloud_setGlobalFilter(aSoloud: [*c]Soloud, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Soloud_setVisualizationEnable(aSoloud: [*c]Soloud, aEnable: c_int) void;
pub extern fn Soloud_calcFFT(aSoloud: [*c]Soloud) [*c]f32;
pub extern fn Soloud_getWave(aSoloud: [*c]Soloud) [*c]f32;
pub extern fn Soloud_getApproximateVolume(aSoloud: [*c]Soloud, aChannel: c_uint) f32;
pub extern fn Soloud_getLoopCount(aSoloud: [*c]Soloud, aVoiceHandle: c_uint) c_uint;
pub extern fn Soloud_getInfo(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aInfoKey: c_uint) f32;
pub extern fn Soloud_createVoiceGroup(aSoloud: [*c]Soloud) c_uint;
pub extern fn Soloud_destroyVoiceGroup(aSoloud: [*c]Soloud, aVoiceGroupHandle: c_uint) c_int;
pub extern fn Soloud_addVoiceToGroup(aSoloud: [*c]Soloud, aVoiceGroupHandle: c_uint, aVoiceHandle: c_uint) c_int;
pub extern fn Soloud_isVoiceGroup(aSoloud: [*c]Soloud, aVoiceGroupHandle: c_uint) c_int;
pub extern fn Soloud_isVoiceGroupEmpty(aSoloud: [*c]Soloud, aVoiceGroupHandle: c_uint) c_int;
pub extern fn Soloud_update3dAudio(aSoloud: [*c]Soloud) void;
pub extern fn Soloud_set3dSoundSpeed(aSoloud: [*c]Soloud, aSpeed: f32) c_int;
pub extern fn Soloud_get3dSoundSpeed(aSoloud: [*c]Soloud) f32;
pub extern fn Soloud_set3dListenerParameters(aSoloud: [*c]Soloud, aPosX: f32, aPosY: f32, aPosZ: f32, aAtX: f32, aAtY: f32, aAtZ: f32, aUpX: f32, aUpY: f32, aUpZ: f32) void;
pub extern fn Soloud_set3dListenerParametersEx(aSoloud: [*c]Soloud, aPosX: f32, aPosY: f32, aPosZ: f32, aAtX: f32, aAtY: f32, aAtZ: f32, aUpX: f32, aUpY: f32, aUpZ: f32, aVelocityX: f32, aVelocityY: f32, aVelocityZ: f32) void;
pub extern fn Soloud_set3dListenerPosition(aSoloud: [*c]Soloud, aPosX: f32, aPosY: f32, aPosZ: f32) void;
pub extern fn Soloud_set3dListenerAt(aSoloud: [*c]Soloud, aAtX: f32, aAtY: f32, aAtZ: f32) void;
pub extern fn Soloud_set3dListenerUp(aSoloud: [*c]Soloud, aUpX: f32, aUpY: f32, aUpZ: f32) void;
pub extern fn Soloud_set3dListenerVelocity(aSoloud: [*c]Soloud, aVelocityX: f32, aVelocityY: f32, aVelocityZ: f32) void;
pub extern fn Soloud_set3dSourceParameters(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aPosX: f32, aPosY: f32, aPosZ: f32) void;
pub extern fn Soloud_set3dSourceParametersEx(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aPosX: f32, aPosY: f32, aPosZ: f32, aVelocityX: f32, aVelocityY: f32, aVelocityZ: f32) void;
pub extern fn Soloud_set3dSourcePosition(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aPosX: f32, aPosY: f32, aPosZ: f32) void;
pub extern fn Soloud_set3dSourceVelocity(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aVelocityX: f32, aVelocityY: f32, aVelocityZ: f32) void;
pub extern fn Soloud_set3dSourceMinMaxDistance(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Soloud_set3dSourceAttenuation(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Soloud_set3dSourceDopplerFactor(aSoloud: [*c]Soloud, aVoiceHandle: c_uint, aDopplerFactor: f32) void;
pub extern fn Soloud_mix(aSoloud: [*c]Soloud, aBuffer: [*c]f32, aSamples: c_uint) void;
pub extern fn Soloud_mixSigned16(aSoloud: [*c]Soloud, aBuffer: [*c]c_short, aSamples: c_uint) void;
pub extern fn Ay_destroy(aAy: [*c]Ay) void;
pub extern fn Ay_create(...) [*c]Ay;
pub extern fn Ay_setVolume(aAy: [*c]Ay, aVolume: f32) void;
pub extern fn Ay_setLooping(aAy: [*c]Ay, aLoop: c_int) void;
pub extern fn Ay_setAutoStop(aAy: [*c]Ay, aAutoStop: c_int) void;
pub extern fn Ay_set3dMinMaxDistance(aAy: [*c]Ay, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Ay_set3dAttenuation(aAy: [*c]Ay, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Ay_set3dDopplerFactor(aAy: [*c]Ay, aDopplerFactor: f32) void;
pub extern fn Ay_set3dListenerRelative(aAy: [*c]Ay, aListenerRelative: c_int) void;
pub extern fn Ay_set3dDistanceDelay(aAy: [*c]Ay, aDistanceDelay: c_int) void;
pub extern fn Ay_set3dCollider(aAy: [*c]Ay, aCollider: [*c]AudioCollider) void;
pub extern fn Ay_set3dColliderEx(aAy: [*c]Ay, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Ay_set3dAttenuator(aAy: [*c]Ay, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Ay_setInaudibleBehavior(aAy: [*c]Ay, aMustTick: c_int, aKill: c_int) void;
pub extern fn Ay_setLoopPoint(aAy: [*c]Ay, aLoopPoint: f64) void;
pub extern fn Ay_getLoopPoint(aAy: [*c]Ay) f64;
pub extern fn Ay_setFilter(aAy: [*c]Ay, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Ay_stop(aAy: [*c]Ay) void;
pub extern fn BassboostFilter_destroy(aBassboostFilter: [*c]BassboostFilter) void;
pub extern fn BassboostFilter_getParamCount(aBassboostFilter: [*c]BassboostFilter) c_int;
pub extern fn BassboostFilter_getParamName(aBassboostFilter: [*c]BassboostFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn BassboostFilter_getParamType(aBassboostFilter: [*c]BassboostFilter, aParamIndex: c_uint) c_uint;
pub extern fn BassboostFilter_getParamMax(aBassboostFilter: [*c]BassboostFilter, aParamIndex: c_uint) f32;
pub extern fn BassboostFilter_getParamMin(aBassboostFilter: [*c]BassboostFilter, aParamIndex: c_uint) f32;
pub extern fn BassboostFilter_setParams(aBassboostFilter: [*c]BassboostFilter, aBoost: f32) c_int;
pub extern fn BassboostFilter_create(...) [*c]BassboostFilter;
pub extern fn BiquadResonantFilter_destroy(aBiquadResonantFilter: [*c]BiquadResonantFilter) void;
pub extern fn BiquadResonantFilter_getParamCount(aBiquadResonantFilter: [*c]BiquadResonantFilter) c_int;
pub extern fn BiquadResonantFilter_getParamName(aBiquadResonantFilter: [*c]BiquadResonantFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn BiquadResonantFilter_getParamType(aBiquadResonantFilter: [*c]BiquadResonantFilter, aParamIndex: c_uint) c_uint;
pub extern fn BiquadResonantFilter_getParamMax(aBiquadResonantFilter: [*c]BiquadResonantFilter, aParamIndex: c_uint) f32;
pub extern fn BiquadResonantFilter_getParamMin(aBiquadResonantFilter: [*c]BiquadResonantFilter, aParamIndex: c_uint) f32;
pub extern fn BiquadResonantFilter_create(...) [*c]BiquadResonantFilter;
pub extern fn BiquadResonantFilter_setParams(aBiquadResonantFilter: [*c]BiquadResonantFilter, aType: c_int, aFrequency: f32, aResonance: f32) c_int;
pub extern fn Bus_destroy(aBus: [*c]Bus) void;
pub extern fn Bus_create(...) [*c]Bus;
pub extern fn Bus_setFilter(aBus: [*c]Bus, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Bus_play(aBus: [*c]Bus, aSound: [*c]AudioSource) c_uint;
pub extern fn Bus_playEx(aBus: [*c]Bus, aSound: [*c]AudioSource, aVolume: f32, aPan: f32, aPaused: c_int) c_uint;
pub extern fn Bus_playClocked(aBus: [*c]Bus, aSoundTime: f64, aSound: [*c]AudioSource) c_uint;
pub extern fn Bus_playClockedEx(aBus: [*c]Bus, aSoundTime: f64, aSound: [*c]AudioSource, aVolume: f32, aPan: f32) c_uint;
pub extern fn Bus_play3d(aBus: [*c]Bus, aSound: [*c]AudioSource, aPosX: f32, aPosY: f32, aPosZ: f32) c_uint;
pub extern fn Bus_play3dEx(aBus: [*c]Bus, aSound: [*c]AudioSource, aPosX: f32, aPosY: f32, aPosZ: f32, aVelX: f32, aVelY: f32, aVelZ: f32, aVolume: f32, aPaused: c_int) c_uint;
pub extern fn Bus_play3dClocked(aBus: [*c]Bus, aSoundTime: f64, aSound: [*c]AudioSource, aPosX: f32, aPosY: f32, aPosZ: f32) c_uint;
pub extern fn Bus_play3dClockedEx(aBus: [*c]Bus, aSoundTime: f64, aSound: [*c]AudioSource, aPosX: f32, aPosY: f32, aPosZ: f32, aVelX: f32, aVelY: f32, aVelZ: f32, aVolume: f32) c_uint;
pub extern fn Bus_setChannels(aBus: [*c]Bus, aChannels: c_uint) c_int;
pub extern fn Bus_setVisualizationEnable(aBus: [*c]Bus, aEnable: c_int) void;
pub extern fn Bus_annexSound(aBus: [*c]Bus, aVoiceHandle: c_uint) void;
pub extern fn Bus_calcFFT(aBus: [*c]Bus) [*c]f32;
pub extern fn Bus_getWave(aBus: [*c]Bus) [*c]f32;
pub extern fn Bus_getApproximateVolume(aBus: [*c]Bus, aChannel: c_uint) f32;
pub extern fn Bus_getActiveVoiceCount(aBus: [*c]Bus) c_uint;
pub extern fn Bus_getResampler(aBus: [*c]Bus) c_uint;
pub extern fn Bus_setResampler(aBus: [*c]Bus, aResampler: c_uint) void;
pub extern fn Bus_setVolume(aBus: [*c]Bus, aVolume: f32) void;
pub extern fn Bus_setLooping(aBus: [*c]Bus, aLoop: c_int) void;
pub extern fn Bus_setAutoStop(aBus: [*c]Bus, aAutoStop: c_int) void;
pub extern fn Bus_set3dMinMaxDistance(aBus: [*c]Bus, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Bus_set3dAttenuation(aBus: [*c]Bus, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Bus_set3dDopplerFactor(aBus: [*c]Bus, aDopplerFactor: f32) void;
pub extern fn Bus_set3dListenerRelative(aBus: [*c]Bus, aListenerRelative: c_int) void;
pub extern fn Bus_set3dDistanceDelay(aBus: [*c]Bus, aDistanceDelay: c_int) void;
pub extern fn Bus_set3dCollider(aBus: [*c]Bus, aCollider: [*c]AudioCollider) void;
pub extern fn Bus_set3dColliderEx(aBus: [*c]Bus, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Bus_set3dAttenuator(aBus: [*c]Bus, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Bus_setInaudibleBehavior(aBus: [*c]Bus, aMustTick: c_int, aKill: c_int) void;
pub extern fn Bus_setLoopPoint(aBus: [*c]Bus, aLoopPoint: f64) void;
pub extern fn Bus_getLoopPoint(aBus: [*c]Bus) f64;
pub extern fn Bus_stop(aBus: [*c]Bus) void;
pub extern fn DCRemovalFilter_destroy(aDCRemovalFilter: [*c]DCRemovalFilter) void;
pub extern fn DCRemovalFilter_create(...) [*c]DCRemovalFilter;
pub extern fn DCRemovalFilter_setParams(aDCRemovalFilter: [*c]DCRemovalFilter) c_int;
pub extern fn DCRemovalFilter_setParamsEx(aDCRemovalFilter: [*c]DCRemovalFilter, aLength: f32) c_int;
pub extern fn DCRemovalFilter_getParamCount(aDCRemovalFilter: [*c]DCRemovalFilter) c_int;
pub extern fn DCRemovalFilter_getParamName(aDCRemovalFilter: [*c]DCRemovalFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn DCRemovalFilter_getParamType(aDCRemovalFilter: [*c]DCRemovalFilter, aParamIndex: c_uint) c_uint;
pub extern fn DCRemovalFilter_getParamMax(aDCRemovalFilter: [*c]DCRemovalFilter, aParamIndex: c_uint) f32;
pub extern fn DCRemovalFilter_getParamMin(aDCRemovalFilter: [*c]DCRemovalFilter, aParamIndex: c_uint) f32;
pub extern fn EchoFilter_destroy(aEchoFilter: [*c]EchoFilter) void;
pub extern fn EchoFilter_getParamCount(aEchoFilter: [*c]EchoFilter) c_int;
pub extern fn EchoFilter_getParamName(aEchoFilter: [*c]EchoFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn EchoFilter_getParamType(aEchoFilter: [*c]EchoFilter, aParamIndex: c_uint) c_uint;
pub extern fn EchoFilter_getParamMax(aEchoFilter: [*c]EchoFilter, aParamIndex: c_uint) f32;
pub extern fn EchoFilter_getParamMin(aEchoFilter: [*c]EchoFilter, aParamIndex: c_uint) f32;
pub extern fn EchoFilter_create(...) [*c]EchoFilter;
pub extern fn EchoFilter_setParams(aEchoFilter: [*c]EchoFilter, aDelay: f32) c_int;
pub extern fn EchoFilter_setParamsEx(aEchoFilter: [*c]EchoFilter, aDelay: f32, aDecay: f32, aFilter: f32) c_int;
pub extern fn FFTFilter_destroy(aFFTFilter: [*c]FFTFilter) void;
pub extern fn FFTFilter_create(...) [*c]FFTFilter;
pub extern fn FFTFilter_getParamCount(aFFTFilter: [*c]FFTFilter) c_int;
pub extern fn FFTFilter_getParamName(aFFTFilter: [*c]FFTFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn FFTFilter_getParamType(aFFTFilter: [*c]FFTFilter, aParamIndex: c_uint) c_uint;
pub extern fn FFTFilter_getParamMax(aFFTFilter: [*c]FFTFilter, aParamIndex: c_uint) f32;
pub extern fn FFTFilter_getParamMin(aFFTFilter: [*c]FFTFilter, aParamIndex: c_uint) f32;
pub extern fn FlangerFilter_destroy(aFlangerFilter: [*c]FlangerFilter) void;
pub extern fn FlangerFilter_getParamCount(aFlangerFilter: [*c]FlangerFilter) c_int;
pub extern fn FlangerFilter_getParamName(aFlangerFilter: [*c]FlangerFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn FlangerFilter_getParamType(aFlangerFilter: [*c]FlangerFilter, aParamIndex: c_uint) c_uint;
pub extern fn FlangerFilter_getParamMax(aFlangerFilter: [*c]FlangerFilter, aParamIndex: c_uint) f32;
pub extern fn FlangerFilter_getParamMin(aFlangerFilter: [*c]FlangerFilter, aParamIndex: c_uint) f32;
pub extern fn FlangerFilter_create(...) [*c]FlangerFilter;
pub extern fn FlangerFilter_setParams(aFlangerFilter: [*c]FlangerFilter, aDelay: f32, aFreq: f32) c_int;
pub extern fn FreeverbFilter_destroy(aFreeverbFilter: [*c]FreeverbFilter) void;
pub extern fn FreeverbFilter_getParamCount(aFreeverbFilter: [*c]FreeverbFilter) c_int;
pub extern fn FreeverbFilter_getParamName(aFreeverbFilter: [*c]FreeverbFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn FreeverbFilter_getParamType(aFreeverbFilter: [*c]FreeverbFilter, aParamIndex: c_uint) c_uint;
pub extern fn FreeverbFilter_getParamMax(aFreeverbFilter: [*c]FreeverbFilter, aParamIndex: c_uint) f32;
pub extern fn FreeverbFilter_getParamMin(aFreeverbFilter: [*c]FreeverbFilter, aParamIndex: c_uint) f32;
pub extern fn FreeverbFilter_create(...) [*c]FreeverbFilter;
pub extern fn FreeverbFilter_setParams(aFreeverbFilter: [*c]FreeverbFilter, aMode: f32, aRoomSize: f32, aDamp: f32, aWidth: f32) c_int;
pub extern fn LofiFilter_destroy(aLofiFilter: [*c]LofiFilter) void;
pub extern fn LofiFilter_getParamCount(aLofiFilter: [*c]LofiFilter) c_int;
pub extern fn LofiFilter_getParamName(aLofiFilter: [*c]LofiFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn LofiFilter_getParamType(aLofiFilter: [*c]LofiFilter, aParamIndex: c_uint) c_uint;
pub extern fn LofiFilter_getParamMax(aLofiFilter: [*c]LofiFilter, aParamIndex: c_uint) f32;
pub extern fn LofiFilter_getParamMin(aLofiFilter: [*c]LofiFilter, aParamIndex: c_uint) f32;
pub extern fn LofiFilter_create(...) [*c]LofiFilter;
pub extern fn LofiFilter_setParams(aLofiFilter: [*c]LofiFilter, aSampleRate: f32, aBitdepth: f32) c_int;
pub extern fn Monotone_destroy(aMonotone: [*c]Monotone) void;
pub extern fn Monotone_create(...) [*c]Monotone;
pub extern fn Monotone_setParams(aMonotone: [*c]Monotone, aHardwareChannels: c_int) c_int;
pub extern fn Monotone_setParamsEx(aMonotone: [*c]Monotone, aHardwareChannels: c_int, aWaveform: c_int) c_int;
pub extern fn Monotone_load(aMonotone: [*c]Monotone, aFilename: [*c]const u8) c_int;
pub extern fn Monotone_loadMem(aMonotone: [*c]Monotone, aMem: [*c]const u8, aLength: c_uint) c_int;
pub extern fn Monotone_loadMemEx(aMonotone: [*c]Monotone, aMem: [*c]const u8, aLength: c_uint, aCopy: c_int, aTakeOwnership: c_int) c_int;
pub extern fn Monotone_loadFile(aMonotone: [*c]Monotone, aFile: [*c]File) c_int;
pub extern fn Monotone_setVolume(aMonotone: [*c]Monotone, aVolume: f32) void;
pub extern fn Monotone_setLooping(aMonotone: [*c]Monotone, aLoop: c_int) void;
pub extern fn Monotone_setAutoStop(aMonotone: [*c]Monotone, aAutoStop: c_int) void;
pub extern fn Monotone_set3dMinMaxDistance(aMonotone: [*c]Monotone, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Monotone_set3dAttenuation(aMonotone: [*c]Monotone, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Monotone_set3dDopplerFactor(aMonotone: [*c]Monotone, aDopplerFactor: f32) void;
pub extern fn Monotone_set3dListenerRelative(aMonotone: [*c]Monotone, aListenerRelative: c_int) void;
pub extern fn Monotone_set3dDistanceDelay(aMonotone: [*c]Monotone, aDistanceDelay: c_int) void;
pub extern fn Monotone_set3dCollider(aMonotone: [*c]Monotone, aCollider: [*c]AudioCollider) void;
pub extern fn Monotone_set3dColliderEx(aMonotone: [*c]Monotone, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Monotone_set3dAttenuator(aMonotone: [*c]Monotone, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Monotone_setInaudibleBehavior(aMonotone: [*c]Monotone, aMustTick: c_int, aKill: c_int) void;
pub extern fn Monotone_setLoopPoint(aMonotone: [*c]Monotone, aLoopPoint: f64) void;
pub extern fn Monotone_getLoopPoint(aMonotone: [*c]Monotone) f64;
pub extern fn Monotone_setFilter(aMonotone: [*c]Monotone, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Monotone_stop(aMonotone: [*c]Monotone) void;
pub extern fn Noise_destroy(aNoise: [*c]Noise) void;
pub extern fn Noise_create(...) [*c]Noise;
pub extern fn Noise_setOctaveScale(aNoise: [*c]Noise, aOct0: f32, aOct1: f32, aOct2: f32, aOct3: f32, aOct4: f32, aOct5: f32, aOct6: f32, aOct7: f32, aOct8: f32, aOct9: f32) void;
pub extern fn Noise_setType(aNoise: [*c]Noise, aType: c_int) void;
pub extern fn Noise_setVolume(aNoise: [*c]Noise, aVolume: f32) void;
pub extern fn Noise_setLooping(aNoise: [*c]Noise, aLoop: c_int) void;
pub extern fn Noise_setAutoStop(aNoise: [*c]Noise, aAutoStop: c_int) void;
pub extern fn Noise_set3dMinMaxDistance(aNoise: [*c]Noise, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Noise_set3dAttenuation(aNoise: [*c]Noise, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Noise_set3dDopplerFactor(aNoise: [*c]Noise, aDopplerFactor: f32) void;
pub extern fn Noise_set3dListenerRelative(aNoise: [*c]Noise, aListenerRelative: c_int) void;
pub extern fn Noise_set3dDistanceDelay(aNoise: [*c]Noise, aDistanceDelay: c_int) void;
pub extern fn Noise_set3dCollider(aNoise: [*c]Noise, aCollider: [*c]AudioCollider) void;
pub extern fn Noise_set3dColliderEx(aNoise: [*c]Noise, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Noise_set3dAttenuator(aNoise: [*c]Noise, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Noise_setInaudibleBehavior(aNoise: [*c]Noise, aMustTick: c_int, aKill: c_int) void;
pub extern fn Noise_setLoopPoint(aNoise: [*c]Noise, aLoopPoint: f64) void;
pub extern fn Noise_getLoopPoint(aNoise: [*c]Noise) f64;
pub extern fn Noise_setFilter(aNoise: [*c]Noise, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Noise_stop(aNoise: [*c]Noise) void;
pub extern fn Openmpt_destroy(aOpenmpt: [*c]Openmpt) void;
pub extern fn Openmpt_create(...) [*c]Openmpt;
pub extern fn Openmpt_load(aOpenmpt: [*c]Openmpt, aFilename: [*c]const u8) c_int;
pub extern fn Openmpt_loadMem(aOpenmpt: [*c]Openmpt, aMem: [*c]const u8, aLength: c_uint) c_int;
pub extern fn Openmpt_loadMemEx(aOpenmpt: [*c]Openmpt, aMem: [*c]const u8, aLength: c_uint, aCopy: c_int, aTakeOwnership: c_int) c_int;
pub extern fn Openmpt_loadFile(aOpenmpt: [*c]Openmpt, aFile: [*c]File) c_int;
pub extern fn Openmpt_setVolume(aOpenmpt: [*c]Openmpt, aVolume: f32) void;
pub extern fn Openmpt_setLooping(aOpenmpt: [*c]Openmpt, aLoop: c_int) void;
pub extern fn Openmpt_setAutoStop(aOpenmpt: [*c]Openmpt, aAutoStop: c_int) void;
pub extern fn Openmpt_set3dMinMaxDistance(aOpenmpt: [*c]Openmpt, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Openmpt_set3dAttenuation(aOpenmpt: [*c]Openmpt, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Openmpt_set3dDopplerFactor(aOpenmpt: [*c]Openmpt, aDopplerFactor: f32) void;
pub extern fn Openmpt_set3dListenerRelative(aOpenmpt: [*c]Openmpt, aListenerRelative: c_int) void;
pub extern fn Openmpt_set3dDistanceDelay(aOpenmpt: [*c]Openmpt, aDistanceDelay: c_int) void;
pub extern fn Openmpt_set3dCollider(aOpenmpt: [*c]Openmpt, aCollider: [*c]AudioCollider) void;
pub extern fn Openmpt_set3dColliderEx(aOpenmpt: [*c]Openmpt, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Openmpt_set3dAttenuator(aOpenmpt: [*c]Openmpt, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Openmpt_setInaudibleBehavior(aOpenmpt: [*c]Openmpt, aMustTick: c_int, aKill: c_int) void;
pub extern fn Openmpt_setLoopPoint(aOpenmpt: [*c]Openmpt, aLoopPoint: f64) void;
pub extern fn Openmpt_getLoopPoint(aOpenmpt: [*c]Openmpt) f64;
pub extern fn Openmpt_setFilter(aOpenmpt: [*c]Openmpt, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Openmpt_stop(aOpenmpt: [*c]Openmpt) void;
pub extern fn Queue_destroy(aQueue: [*c]Queue) void;
pub extern fn Queue_create(...) [*c]Queue;
pub extern fn Queue_play(aQueue: [*c]Queue, aSound: [*c]AudioSource) c_int;
pub extern fn Queue_getQueueCount(aQueue: [*c]Queue) c_uint;
pub extern fn Queue_isCurrentlyPlaying(aQueue: [*c]Queue, aSound: [*c]AudioSource) c_int;
pub extern fn Queue_setParamsFromAudioSource(aQueue: [*c]Queue, aSound: [*c]AudioSource) c_int;
pub extern fn Queue_setParams(aQueue: [*c]Queue, aSamplerate: f32) c_int;
pub extern fn Queue_setParamsEx(aQueue: [*c]Queue, aSamplerate: f32, aChannels: c_uint) c_int;
pub extern fn Queue_setVolume(aQueue: [*c]Queue, aVolume: f32) void;
pub extern fn Queue_setLooping(aQueue: [*c]Queue, aLoop: c_int) void;
pub extern fn Queue_setAutoStop(aQueue: [*c]Queue, aAutoStop: c_int) void;
pub extern fn Queue_set3dMinMaxDistance(aQueue: [*c]Queue, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Queue_set3dAttenuation(aQueue: [*c]Queue, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Queue_set3dDopplerFactor(aQueue: [*c]Queue, aDopplerFactor: f32) void;
pub extern fn Queue_set3dListenerRelative(aQueue: [*c]Queue, aListenerRelative: c_int) void;
pub extern fn Queue_set3dDistanceDelay(aQueue: [*c]Queue, aDistanceDelay: c_int) void;
pub extern fn Queue_set3dCollider(aQueue: [*c]Queue, aCollider: [*c]AudioCollider) void;
pub extern fn Queue_set3dColliderEx(aQueue: [*c]Queue, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Queue_set3dAttenuator(aQueue: [*c]Queue, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Queue_setInaudibleBehavior(aQueue: [*c]Queue, aMustTick: c_int, aKill: c_int) void;
pub extern fn Queue_setLoopPoint(aQueue: [*c]Queue, aLoopPoint: f64) void;
pub extern fn Queue_getLoopPoint(aQueue: [*c]Queue) f64;
pub extern fn Queue_setFilter(aQueue: [*c]Queue, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Queue_stop(aQueue: [*c]Queue) void;
pub extern fn RobotizeFilter_destroy(aRobotizeFilter: [*c]RobotizeFilter) void;
pub extern fn RobotizeFilter_getParamCount(aRobotizeFilter: [*c]RobotizeFilter) c_int;
pub extern fn RobotizeFilter_getParamName(aRobotizeFilter: [*c]RobotizeFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn RobotizeFilter_getParamType(aRobotizeFilter: [*c]RobotizeFilter, aParamIndex: c_uint) c_uint;
pub extern fn RobotizeFilter_getParamMax(aRobotizeFilter: [*c]RobotizeFilter, aParamIndex: c_uint) f32;
pub extern fn RobotizeFilter_getParamMin(aRobotizeFilter: [*c]RobotizeFilter, aParamIndex: c_uint) f32;
pub extern fn RobotizeFilter_setParams(aRobotizeFilter: [*c]RobotizeFilter, aFreq: f32, aWaveform: c_int) void;
pub extern fn RobotizeFilter_create(...) [*c]RobotizeFilter;
pub extern fn Sfxr_destroy(aSfxr: [*c]Sfxr) void;
pub extern fn Sfxr_create(...) [*c]Sfxr;
pub extern fn Sfxr_resetParams(aSfxr: [*c]Sfxr) void;
pub extern fn Sfxr_loadParams(aSfxr: [*c]Sfxr, aFilename: [*c]const u8) c_int;
pub extern fn Sfxr_loadParamsMem(aSfxr: [*c]Sfxr, aMem: [*c]u8, aLength: c_uint) c_int;
pub extern fn Sfxr_loadParamsMemEx(aSfxr: [*c]Sfxr, aMem: [*c]u8, aLength: c_uint, aCopy: c_int, aTakeOwnership: c_int) c_int;
pub extern fn Sfxr_loadParamsFile(aSfxr: [*c]Sfxr, aFile: [*c]File) c_int;
pub extern fn Sfxr_loadPreset(aSfxr: [*c]Sfxr, aPresetNo: c_int, aRandSeed: c_int) c_int;
pub extern fn Sfxr_setVolume(aSfxr: [*c]Sfxr, aVolume: f32) void;
pub extern fn Sfxr_setLooping(aSfxr: [*c]Sfxr, aLoop: c_int) void;
pub extern fn Sfxr_setAutoStop(aSfxr: [*c]Sfxr, aAutoStop: c_int) void;
pub extern fn Sfxr_set3dMinMaxDistance(aSfxr: [*c]Sfxr, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Sfxr_set3dAttenuation(aSfxr: [*c]Sfxr, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Sfxr_set3dDopplerFactor(aSfxr: [*c]Sfxr, aDopplerFactor: f32) void;
pub extern fn Sfxr_set3dListenerRelative(aSfxr: [*c]Sfxr, aListenerRelative: c_int) void;
pub extern fn Sfxr_set3dDistanceDelay(aSfxr: [*c]Sfxr, aDistanceDelay: c_int) void;
pub extern fn Sfxr_set3dCollider(aSfxr: [*c]Sfxr, aCollider: [*c]AudioCollider) void;
pub extern fn Sfxr_set3dColliderEx(aSfxr: [*c]Sfxr, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Sfxr_set3dAttenuator(aSfxr: [*c]Sfxr, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Sfxr_setInaudibleBehavior(aSfxr: [*c]Sfxr, aMustTick: c_int, aKill: c_int) void;
pub extern fn Sfxr_setLoopPoint(aSfxr: [*c]Sfxr, aLoopPoint: f64) void;
pub extern fn Sfxr_getLoopPoint(aSfxr: [*c]Sfxr) f64;
pub extern fn Sfxr_setFilter(aSfxr: [*c]Sfxr, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Sfxr_stop(aSfxr: [*c]Sfxr) void;
pub extern fn Speech_destroy(aSpeech: [*c]Speech) void;
pub extern fn Speech_create(...) [*c]Speech;
pub extern fn Speech_setText(aSpeech: [*c]Speech, aText: [*c]const u8) c_int;
pub extern fn Speech_setParams(aSpeech: [*c]Speech) c_int;
pub extern fn Speech_setParamsEx(aSpeech: [*c]Speech, aBaseFrequency: c_uint, aBaseSpeed: f32, aBaseDeclination: f32, aBaseWaveform: c_int) c_int;
pub extern fn Speech_setVolume(aSpeech: [*c]Speech, aVolume: f32) void;
pub extern fn Speech_setLooping(aSpeech: [*c]Speech, aLoop: c_int) void;
pub extern fn Speech_setAutoStop(aSpeech: [*c]Speech, aAutoStop: c_int) void;
pub extern fn Speech_set3dMinMaxDistance(aSpeech: [*c]Speech, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Speech_set3dAttenuation(aSpeech: [*c]Speech, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Speech_set3dDopplerFactor(aSpeech: [*c]Speech, aDopplerFactor: f32) void;
pub extern fn Speech_set3dListenerRelative(aSpeech: [*c]Speech, aListenerRelative: c_int) void;
pub extern fn Speech_set3dDistanceDelay(aSpeech: [*c]Speech, aDistanceDelay: c_int) void;
pub extern fn Speech_set3dCollider(aSpeech: [*c]Speech, aCollider: [*c]AudioCollider) void;
pub extern fn Speech_set3dColliderEx(aSpeech: [*c]Speech, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Speech_set3dAttenuator(aSpeech: [*c]Speech, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Speech_setInaudibleBehavior(aSpeech: [*c]Speech, aMustTick: c_int, aKill: c_int) void;
pub extern fn Speech_setLoopPoint(aSpeech: [*c]Speech, aLoopPoint: f64) void;
pub extern fn Speech_getLoopPoint(aSpeech: [*c]Speech) f64;
pub extern fn Speech_setFilter(aSpeech: [*c]Speech, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Speech_stop(aSpeech: [*c]Speech) void;
pub extern fn TedSid_destroy(aTedSid: [*c]TedSid) void;
pub extern fn TedSid_create(...) [*c]TedSid;
pub extern fn TedSid_load(aTedSid: [*c]TedSid, aFilename: [*c]const u8) c_int;
pub extern fn TedSid_loadMem(aTedSid: [*c]TedSid, aMem: [*c]const u8, aLength: c_uint) c_int;
pub extern fn TedSid_loadMemEx(aTedSid: [*c]TedSid, aMem: [*c]const u8, aLength: c_uint, aCopy: c_int, aTakeOwnership: c_int) c_int;
pub extern fn TedSid_loadFile(aTedSid: [*c]TedSid, aFile: [*c]File) c_int;
pub extern fn TedSid_setVolume(aTedSid: [*c]TedSid, aVolume: f32) void;
pub extern fn TedSid_setLooping(aTedSid: [*c]TedSid, aLoop: c_int) void;
pub extern fn TedSid_setAutoStop(aTedSid: [*c]TedSid, aAutoStop: c_int) void;
pub extern fn TedSid_set3dMinMaxDistance(aTedSid: [*c]TedSid, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn TedSid_set3dAttenuation(aTedSid: [*c]TedSid, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn TedSid_set3dDopplerFactor(aTedSid: [*c]TedSid, aDopplerFactor: f32) void;
pub extern fn TedSid_set3dListenerRelative(aTedSid: [*c]TedSid, aListenerRelative: c_int) void;
pub extern fn TedSid_set3dDistanceDelay(aTedSid: [*c]TedSid, aDistanceDelay: c_int) void;
pub extern fn TedSid_set3dCollider(aTedSid: [*c]TedSid, aCollider: [*c]AudioCollider) void;
pub extern fn TedSid_set3dColliderEx(aTedSid: [*c]TedSid, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn TedSid_set3dAttenuator(aTedSid: [*c]TedSid, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn TedSid_setInaudibleBehavior(aTedSid: [*c]TedSid, aMustTick: c_int, aKill: c_int) void;
pub extern fn TedSid_setLoopPoint(aTedSid: [*c]TedSid, aLoopPoint: f64) void;
pub extern fn TedSid_getLoopPoint(aTedSid: [*c]TedSid) f64;
pub extern fn TedSid_setFilter(aTedSid: [*c]TedSid, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn TedSid_stop(aTedSid: [*c]TedSid) void;
pub extern fn Vic_destroy(aVic: [*c]Vic) void;
pub extern fn Vic_create(...) [*c]Vic;
pub extern fn Vic_setModel(aVic: [*c]Vic, model: c_int) void;
pub extern fn Vic_getModel(aVic: [*c]Vic) c_int;
pub extern fn Vic_setRegister(aVic: [*c]Vic, reg: c_int, value: u8) void;
pub extern fn Vic_getRegister(aVic: [*c]Vic, reg: c_int) u8;
pub extern fn Vic_setVolume(aVic: [*c]Vic, aVolume: f32) void;
pub extern fn Vic_setLooping(aVic: [*c]Vic, aLoop: c_int) void;
pub extern fn Vic_setAutoStop(aVic: [*c]Vic, aAutoStop: c_int) void;
pub extern fn Vic_set3dMinMaxDistance(aVic: [*c]Vic, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Vic_set3dAttenuation(aVic: [*c]Vic, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Vic_set3dDopplerFactor(aVic: [*c]Vic, aDopplerFactor: f32) void;
pub extern fn Vic_set3dListenerRelative(aVic: [*c]Vic, aListenerRelative: c_int) void;
pub extern fn Vic_set3dDistanceDelay(aVic: [*c]Vic, aDistanceDelay: c_int) void;
pub extern fn Vic_set3dCollider(aVic: [*c]Vic, aCollider: [*c]AudioCollider) void;
pub extern fn Vic_set3dColliderEx(aVic: [*c]Vic, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Vic_set3dAttenuator(aVic: [*c]Vic, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Vic_setInaudibleBehavior(aVic: [*c]Vic, aMustTick: c_int, aKill: c_int) void;
pub extern fn Vic_setLoopPoint(aVic: [*c]Vic, aLoopPoint: f64) void;
pub extern fn Vic_getLoopPoint(aVic: [*c]Vic) f64;
pub extern fn Vic_setFilter(aVic: [*c]Vic, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Vic_stop(aVic: [*c]Vic) void;
pub extern fn Vizsn_destroy(aVizsn: [*c]Vizsn) void;
pub extern fn Vizsn_create(...) [*c]Vizsn;
pub extern fn Vizsn_setText(aVizsn: [*c]Vizsn, aText: [*c]u8) void;
pub extern fn Vizsn_setVolume(aVizsn: [*c]Vizsn, aVolume: f32) void;
pub extern fn Vizsn_setLooping(aVizsn: [*c]Vizsn, aLoop: c_int) void;
pub extern fn Vizsn_setAutoStop(aVizsn: [*c]Vizsn, aAutoStop: c_int) void;
pub extern fn Vizsn_set3dMinMaxDistance(aVizsn: [*c]Vizsn, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Vizsn_set3dAttenuation(aVizsn: [*c]Vizsn, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Vizsn_set3dDopplerFactor(aVizsn: [*c]Vizsn, aDopplerFactor: f32) void;
pub extern fn Vizsn_set3dListenerRelative(aVizsn: [*c]Vizsn, aListenerRelative: c_int) void;
pub extern fn Vizsn_set3dDistanceDelay(aVizsn: [*c]Vizsn, aDistanceDelay: c_int) void;
pub extern fn Vizsn_set3dCollider(aVizsn: [*c]Vizsn, aCollider: [*c]AudioCollider) void;
pub extern fn Vizsn_set3dColliderEx(aVizsn: [*c]Vizsn, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Vizsn_set3dAttenuator(aVizsn: [*c]Vizsn, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Vizsn_setInaudibleBehavior(aVizsn: [*c]Vizsn, aMustTick: c_int, aKill: c_int) void;
pub extern fn Vizsn_setLoopPoint(aVizsn: [*c]Vizsn, aLoopPoint: f64) void;
pub extern fn Vizsn_getLoopPoint(aVizsn: [*c]Vizsn) f64;
pub extern fn Vizsn_setFilter(aVizsn: [*c]Vizsn, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Vizsn_stop(aVizsn: [*c]Vizsn) void;
pub extern fn Wav_destroy(aWav: [*c]Wav) void;
pub extern fn Wav_create(...) [*c]Wav;
pub extern fn Wav_load(aWav: [*c]Wav, aFilename: [*c]const u8) c_int;
pub extern fn Wav_loadMem(aWav: [*c]Wav, aMem: [*c]const u8, aLength: c_uint) c_int;
pub extern fn Wav_loadMemEx(aWav: [*c]Wav, aMem: [*c]const u8, aLength: c_uint, aCopy: c_int, aTakeOwnership: c_int) c_int;
pub extern fn Wav_loadFile(aWav: [*c]Wav, aFile: [*c]File) c_int;
pub extern fn Wav_loadRawWave8(aWav: [*c]Wav, aMem: [*c]u8, aLength: c_uint) c_int;
pub extern fn Wav_loadRawWave8Ex(aWav: [*c]Wav, aMem: [*c]u8, aLength: c_uint, aSamplerate: f32, aChannels: c_uint) c_int;
pub extern fn Wav_loadRawWave16(aWav: [*c]Wav, aMem: [*c]c_short, aLength: c_uint) c_int;
pub extern fn Wav_loadRawWave16Ex(aWav: [*c]Wav, aMem: [*c]c_short, aLength: c_uint, aSamplerate: f32, aChannels: c_uint) c_int;
pub extern fn Wav_loadRawWave(aWav: [*c]Wav, aMem: [*c]f32, aLength: c_uint) c_int;
pub extern fn Wav_loadRawWaveEx(aWav: [*c]Wav, aMem: [*c]f32, aLength: c_uint, aSamplerate: f32, aChannels: c_uint, aCopy: c_int, aTakeOwnership: c_int) c_int;
pub extern fn Wav_getLength(aWav: [*c]Wav) f64;
pub extern fn Wav_setVolume(aWav: [*c]Wav, aVolume: f32) void;
pub extern fn Wav_setLooping(aWav: [*c]Wav, aLoop: c_int) void;
pub extern fn Wav_setAutoStop(aWav: [*c]Wav, aAutoStop: c_int) void;
pub extern fn Wav_set3dMinMaxDistance(aWav: [*c]Wav, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn Wav_set3dAttenuation(aWav: [*c]Wav, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn Wav_set3dDopplerFactor(aWav: [*c]Wav, aDopplerFactor: f32) void;
pub extern fn Wav_set3dListenerRelative(aWav: [*c]Wav, aListenerRelative: c_int) void;
pub extern fn Wav_set3dDistanceDelay(aWav: [*c]Wav, aDistanceDelay: c_int) void;
pub extern fn Wav_set3dCollider(aWav: [*c]Wav, aCollider: [*c]AudioCollider) void;
pub extern fn Wav_set3dColliderEx(aWav: [*c]Wav, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn Wav_set3dAttenuator(aWav: [*c]Wav, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn Wav_setInaudibleBehavior(aWav: [*c]Wav, aMustTick: c_int, aKill: c_int) void;
pub extern fn Wav_setLoopPoint(aWav: [*c]Wav, aLoopPoint: f64) void;
pub extern fn Wav_getLoopPoint(aWav: [*c]Wav) f64;
pub extern fn Wav_setFilter(aWav: [*c]Wav, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn Wav_stop(aWav: [*c]Wav) void;
pub extern fn WaveShaperFilter_destroy(aWaveShaperFilter: [*c]WaveShaperFilter) void;
pub extern fn WaveShaperFilter_setParams(aWaveShaperFilter: [*c]WaveShaperFilter, aAmount: f32) c_int;
pub extern fn WaveShaperFilter_create(...) [*c]WaveShaperFilter;
pub extern fn WaveShaperFilter_getParamCount(aWaveShaperFilter: [*c]WaveShaperFilter) c_int;
pub extern fn WaveShaperFilter_getParamName(aWaveShaperFilter: [*c]WaveShaperFilter, aParamIndex: c_uint) [*c]const u8;
pub extern fn WaveShaperFilter_getParamType(aWaveShaperFilter: [*c]WaveShaperFilter, aParamIndex: c_uint) c_uint;
pub extern fn WaveShaperFilter_getParamMax(aWaveShaperFilter: [*c]WaveShaperFilter, aParamIndex: c_uint) f32;
pub extern fn WaveShaperFilter_getParamMin(aWaveShaperFilter: [*c]WaveShaperFilter, aParamIndex: c_uint) f32;
pub extern fn WavStream_destroy(aWavStream: [*c]WavStream) void;
pub extern fn WavStream_create(...) [*c]WavStream;
pub extern fn WavStream_load(aWavStream: [*c]WavStream, aFilename: [*c]const u8) c_int;
pub extern fn WavStream_loadMem(aWavStream: [*c]WavStream, aData: [*c]const u8, aDataLen: c_uint) c_int;
pub extern fn WavStream_loadMemEx(aWavStream: [*c]WavStream, aData: [*c]const u8, aDataLen: c_uint, aCopy: c_int, aTakeOwnership: c_int) c_int;
pub extern fn WavStream_loadToMem(aWavStream: [*c]WavStream, aFilename: [*c]const u8) c_int;
pub extern fn WavStream_loadFile(aWavStream: [*c]WavStream, aFile: [*c]File) c_int;
pub extern fn WavStream_loadFileToMem(aWavStream: [*c]WavStream, aFile: [*c]File) c_int;
pub extern fn WavStream_getLength(aWavStream: [*c]WavStream) f64;
pub extern fn WavStream_setVolume(aWavStream: [*c]WavStream, aVolume: f32) void;
pub extern fn WavStream_setLooping(aWavStream: [*c]WavStream, aLoop: c_int) void;
pub extern fn WavStream_setAutoStop(aWavStream: [*c]WavStream, aAutoStop: c_int) void;
pub extern fn WavStream_set3dMinMaxDistance(aWavStream: [*c]WavStream, aMinDistance: f32, aMaxDistance: f32) void;
pub extern fn WavStream_set3dAttenuation(aWavStream: [*c]WavStream, aAttenuationModel: c_uint, aAttenuationRolloffFactor: f32) void;
pub extern fn WavStream_set3dDopplerFactor(aWavStream: [*c]WavStream, aDopplerFactor: f32) void;
pub extern fn WavStream_set3dListenerRelative(aWavStream: [*c]WavStream, aListenerRelative: c_int) void;
pub extern fn WavStream_set3dDistanceDelay(aWavStream: [*c]WavStream, aDistanceDelay: c_int) void;
pub extern fn WavStream_set3dCollider(aWavStream: [*c]WavStream, aCollider: [*c]AudioCollider) void;
pub extern fn WavStream_set3dColliderEx(aWavStream: [*c]WavStream, aCollider: [*c]AudioCollider, aUserData: c_int) void;
pub extern fn WavStream_set3dAttenuator(aWavStream: [*c]WavStream, aAttenuator: [*c]AudioAttenuator) void;
pub extern fn WavStream_setInaudibleBehavior(aWavStream: [*c]WavStream, aMustTick: c_int, aKill: c_int) void;
pub extern fn WavStream_setLoopPoint(aWavStream: [*c]WavStream, aLoopPoint: f64) void;
pub extern fn WavStream_getLoopPoint(aWavStream: [*c]WavStream) f64;
pub extern fn WavStream_setFilter(aWavStream: [*c]WavStream, aFilterId: c_uint, aFilter: [*c]Filter) void;
pub extern fn WavStream_stop(aWavStream: [*c]WavStream) void;
pub const __INTMAX_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_int"); // (no file):64:9
pub const __UINTMAX_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_unsigned"); // (no file):68:9
pub const __PTRDIFF_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_int"); // (no file):75:9
pub const __INTPTR_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_int"); // (no file):79:9
pub const __SIZE_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_unsigned"); // (no file):83:9
pub const __CHAR16_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_short"); // (no file):95:9
pub const __CHAR32_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_int"); // (no file):96:9
pub const __UINTPTR_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_unsigned"); // (no file):98:9
pub const __INT8_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_signed"); // (no file):148:9
pub const __INT64_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_long"); // (no file):160:9
pub const __UINT8_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_char"); // (no file):164:9
pub const __UINT16_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_short"); // (no file):172:9
pub const __UINT32_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_int"); // (no file):180:9
pub const __UINT64_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_long"); // (no file):188:9
pub const __INT_LEAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_signed"); // (no file):196:9
pub const __UINT_LEAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_char"); // (no file):200:9
pub const __UINT_LEAST16_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_short"); // (no file):210:9
pub const __UINT_LEAST32_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_int"); // (no file):220:9
pub const __INT_LEAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_long"); // (no file):226:9
pub const __UINT_LEAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_long"); // (no file):230:9
pub const __INT_FAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_signed"); // (no file):236:9
pub const __UINT_FAST8_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_char"); // (no file):240:9
pub const __UINT_FAST16_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_short"); // (no file):250:9
pub const __UINT_FAST32_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_int"); // (no file):260:9
pub const __INT_FAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_long"); // (no file):266:9
pub const __UINT_FAST64_TYPE__ = @compileError("unable to translate C expr: unexpected token .Keyword_long"); // (no file):270:9
pub const __llvm__ = 1;
pub const __clang__ = 1;
pub const __clang_major__ = 10;
pub const __clang_minor__ = 0;
pub const __clang_patchlevel__ = 0;
pub const __clang_version__ = "10.0.0 ";
pub const __GNUC__ = 4;
pub const __GNUC_MINOR__ = 2;
pub const __GNUC_PATCHLEVEL__ = 1;
pub const __GXX_ABI_VERSION = 1002;
pub const __ATOMIC_RELAXED = 0;
pub const __ATOMIC_CONSUME = 1;
pub const __ATOMIC_ACQUIRE = 2;
pub const __ATOMIC_RELEASE = 3;
pub const __ATOMIC_ACQ_REL = 4;
pub const __ATOMIC_SEQ_CST = 5;
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = 0;
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = 1;
pub const __OPENCL_MEMORY_SCOPE_DEVICE = 2;
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = 3;
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = 4;
pub const __PRAGMA_REDEFINE_EXTNAME = 1;
pub const __VERSION__ = "Clang 10.0.0 ";
pub const __OBJC_BOOL_IS_BOOL = 0;
pub const __CONSTANT_CFSTRINGS__ = 1;
pub const __block = __attribute__(__blocks__(byref));
pub const __BLOCKS__ = 1;
pub const __OPTIMIZE__ = 1;
pub const __ORDER_LITTLE_ENDIAN__ = 1234;
pub const __ORDER_BIG_ENDIAN__ = 4321;
pub const __ORDER_PDP_ENDIAN__ = 3412;
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = 1;
pub const _LP64 = 1;
pub const __LP64__ = 1;
pub const __CHAR_BIT__ = 8;
pub const __SCHAR_MAX__ = 127;
pub const __SHRT_MAX__ = 32767;
pub const __INT_MAX__ = 2147483647;
pub const __LONG_MAX__ = @as(c_long, 9223372036854775807);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __WCHAR_MAX__ = 2147483647;
pub const __WINT_MAX__ = 2147483647;
pub const __INTMAX_MAX__ = @as(c_long, 9223372036854775807);
pub const __SIZE_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __UINTMAX_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __PTRDIFF_MAX__ = @as(c_long, 9223372036854775807);
pub const __INTPTR_MAX__ = @as(c_long, 9223372036854775807);
pub const __UINTPTR_MAX__ = @as(c_ulong, 18446744073709551615);
pub const __SIZEOF_DOUBLE__ = 8;
pub const __SIZEOF_FLOAT__ = 4;
pub const __SIZEOF_INT__ = 4;
pub const __SIZEOF_LONG__ = 8;
pub const __SIZEOF_LONG_DOUBLE__ = 16;
pub const __SIZEOF_LONG_LONG__ = 8;
pub const __SIZEOF_POINTER__ = 8;
pub const __SIZEOF_SHORT__ = 2;
pub const __SIZEOF_PTRDIFF_T__ = 8;
pub const __SIZEOF_SIZE_T__ = 8;
pub const __SIZEOF_WCHAR_T__ = 4;
pub const __SIZEOF_WINT_T__ = 4;
pub const __SIZEOF_INT128__ = 16;
pub const __INTMAX_FMTd__ = "ld";
pub const __INTMAX_FMTi__ = "li";
pub const __INTMAX_C_SUFFIX__ = L;
pub const __UINTMAX_FMTo__ = "lo";
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINTMAX_FMTX__ = "lX";
pub const __UINTMAX_C_SUFFIX__ = UL;
pub const __INTMAX_WIDTH__ = 64;
pub const __PTRDIFF_FMTd__ = "ld";
pub const __PTRDIFF_FMTi__ = "li";
pub const __PTRDIFF_WIDTH__ = 64;
pub const __INTPTR_FMTd__ = "ld";
pub const __INTPTR_FMTi__ = "li";
pub const __INTPTR_WIDTH__ = 64;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZE_FMTx__ = "lx";
pub const __SIZE_FMTX__ = "lX";
pub const __SIZE_WIDTH__ = 64;
pub const __WCHAR_TYPE__ = c_int;
pub const __WCHAR_WIDTH__ = 32;
pub const __WINT_TYPE__ = c_int;
pub const __WINT_WIDTH__ = 32;
pub const __SIG_ATOMIC_WIDTH__ = 32;
pub const __SIG_ATOMIC_MAX__ = 2147483647;
pub const __UINTMAX_WIDTH__ = 64;
pub const __UINTPTR_FMTo__ = "lo";
pub const __UINTPTR_FMTu__ = "lu";
pub const __UINTPTR_FMTx__ = "lx";
pub const __UINTPTR_FMTX__ = "lX";
pub const __UINTPTR_WIDTH__ = 64;
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = 1;
pub const __FLT_DIG__ = 6;
pub const __FLT_DECIMAL_DIG__ = 9;
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = 1;
pub const __FLT_HAS_QUIET_NAN__ = 1;
pub const __FLT_MANT_DIG__ = 24;
pub const __FLT_MAX_10_EXP__ = 38;
pub const __FLT_MAX_EXP__ = 128;
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -37;
pub const __FLT_MIN_EXP__ = -125;
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = 4.9406564584124654e-324;
pub const __DBL_HAS_DENORM__ = 1;
pub const __DBL_DIG__ = 15;
pub const __DBL_DECIMAL_DIG__ = 17;
pub const __DBL_EPSILON__ = 2.2204460492503131e-16;
pub const __DBL_HAS_INFINITY__ = 1;
pub const __DBL_HAS_QUIET_NAN__ = 1;
pub const __DBL_MANT_DIG__ = 53;
pub const __DBL_MAX_10_EXP__ = 308;
pub const __DBL_MAX_EXP__ = 1024;
pub const __DBL_MAX__ = 1.7976931348623157e+308;
pub const __DBL_MIN_10_EXP__ = -307;
pub const __DBL_MIN_EXP__ = -1021;
pub const __DBL_MIN__ = 2.2250738585072014e-308;
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = 1;
pub const __LDBL_DIG__ = 18;
pub const __LDBL_DECIMAL_DIG__ = 21;
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = 1;
pub const __LDBL_HAS_QUIET_NAN__ = 1;
pub const __LDBL_MANT_DIG__ = 64;
pub const __LDBL_MAX_10_EXP__ = 4932;
pub const __LDBL_MAX_EXP__ = 16384;
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -4931;
pub const __LDBL_MIN_EXP__ = -16381;
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __POINTER_WIDTH__ = 64;
pub const __BIGGEST_ALIGNMENT__ = 16;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT64_FMTd__ = "lld";
pub const __INT64_FMTi__ = "lli";
pub const __INT64_C_SUFFIX__ = LL;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_MAX__ = 255;
pub const __INT8_MAX__ = 127;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_MAX__ = 65535;
pub const __INT16_MAX__ = 32767;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = U;
pub const __UINT32_MAX__ = @as(c_uint, 4294967295);
pub const __INT32_MAX__ = 2147483647;
pub const __UINT64_FMTo__ = "llo";
pub const __UINT64_FMTu__ = "llu";
pub const __UINT64_FMTx__ = "llx";
pub const __UINT64_FMTX__ = "llX";
pub const __UINT64_C_SUFFIX__ = ULL;
pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST8_MAX__ = 127;
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_MAX__ = 255;
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = 32767;
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_MAX__ = 65535;
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = 2147483647;
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_MAX__ = @as(c_uint, 4294967295);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST64_FMTd__ = "lld";
pub const __INT_LEAST64_FMTi__ = "lli";
pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_LEAST64_FMTo__ = "llo";
pub const __UINT_LEAST64_FMTu__ = "llu";
pub const __UINT_LEAST64_FMTx__ = "llx";
pub const __UINT_LEAST64_FMTX__ = "llX";
pub const __INT_FAST8_MAX__ = 127;
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_MAX__ = 255;
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = 32767;
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_MAX__ = 65535;
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = 2147483647;
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_MAX__ = @as(c_uint, 4294967295);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_FAST64_FMTd__ = "lld";
pub const __INT_FAST64_FMTi__ = "lli";
pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_FAST64_FMTo__ = "llo";
pub const __UINT_FAST64_FMTu__ = "llu";
pub const __UINT_FAST64_FMTx__ = "llx";
pub const __UINT_FAST64_FMTX__ = "llX";
pub const __USER_LABEL_PREFIX__ = _;
pub const __FINITE_MATH_ONLY__ = 0;
pub const __GNUC_STDC_INLINE__ = 1;
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = 1;
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_INT_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = 2;
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = 2;
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = 2;
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = 2;
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = 2;
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = 2;
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = 2;
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = 2;
pub const __GCC_ATOMIC_INT_LOCK_FREE = 2;
pub const __GCC_ATOMIC_LONG_LOCK_FREE = 2;
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = 2;
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = 2;
pub const __PIC__ = 2;
pub const __pic__ = 2;
pub const __FLT_EVAL_METHOD__ = 0;
pub const __FLT_RADIX__ = 2;
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __SSP_STRONG__ = 2;
pub const __nonnull = _Nonnull;
pub const __null_unspecified = _Null_unspecified;
pub const __nullable = _Nullable;
pub const __GCC_ASM_FLAG_OUTPUTS__ = 1;
pub const __code_model_small_ = 1;
pub const __amd64__ = 1;
pub const __amd64 = 1;
pub const __x86_64 = 1;
pub const __x86_64__ = 1;
pub const __SEG_GS = 1;
pub const __SEG_FS = 1;
pub const __seg_gs = __attribute__(address_space(256));
pub const __seg_fs = __attribute__(address_space(257));
pub const __corei7 = 1;
pub const __corei7__ = 1;
pub const __tune_corei7__ = 1;
pub const __NO_MATH_INLINES = 1;
pub const __AES__ = 1;
pub const __PCLMUL__ = 1;
pub const __LZCNT__ = 1;
pub const __RDRND__ = 1;
pub const __FSGSBASE__ = 1;
pub const __BMI__ = 1;
pub const __BMI2__ = 1;
pub const __POPCNT__ = 1;
pub const __RTM__ = 1;
pub const __PRFCHW__ = 1;
pub const __RDSEED__ = 1;
pub const __ADX__ = 1;
pub const __MOVBE__ = 1;
pub const __FMA__ = 1;
pub const __F16C__ = 1;
pub const __FXSR__ = 1;
pub const __XSAVE__ = 1;
pub const __XSAVEOPT__ = 1;
pub const __XSAVEC__ = 1;
pub const __XSAVES__ = 1;
pub const __CLFLUSHOPT__ = 1;
pub const __SGX__ = 1;
pub const __INVPCID__ = 1;
pub const __AVX2__ = 1;
pub const __AVX__ = 1;
pub const __SSE4_2__ = 1;
pub const __SSE4_1__ = 1;
pub const __SSSE3__ = 1;
pub const __SSE3__ = 1;
pub const __SSE2__ = 1;
pub const __SSE2_MATH__ = 1;
pub const __SSE__ = 1;
pub const __SSE_MATH__ = 1;
pub const __MMX__ = 1;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = 1;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = 1;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = 1;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = 1;
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = 1;
pub const __APPLE_CC__ = 6000;
pub const __APPLE__ = 1;
pub const __STDC_NO_THREADS__ = 1;
pub const OBJC_NEW_PROPERTIES = 1;
pub const __weak = __attribute__(objc_gc(weak));
pub const __DYNAMIC__ = 1;
pub const __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ = 101500;
pub const __MACH__ = 1;
pub const __STDC__ = 1;
pub const __STDC_HOSTED__ = 1;
pub const __STDC_VERSION__ = @as(c_long, 201112);
pub const __STDC_UTF_16__ = 1;
pub const __STDC_UTF_32__ = 1;
pub const _LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS = 1;
pub const _LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS = 1;
pub const _DEBUG = 1;
pub const _THREAD_SAFE = 1;
pub const WITH_SDL2 = 1;
pub const SOLOUD_ENUMS = enum_SOLOUD_ENUMS;
