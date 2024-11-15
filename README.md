![Release](https://img.shields.io/github/v/release/CrimeIsDown/whisper-asr-webservice.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/onerahmet/openai-whisper-asr-webservice.svg)
![Build](https://img.shields.io/github/actions/workflow/status/CrimeIsDown/whisper-asr-webservice/docker-publish.yml.svg)
![Licence](https://img.shields.io/github/license/CrimeIsDown/whisper-asr-webservice.svg)

# Whisper ASR Webservice

Whisper is a general-purpose speech recognition model. It is trained on a large dataset of diverse audio and is also a multitask model that can perform multilingual speech recognition as well as speech translation and language identification. For more details: [github.com/openai/whisper](https://github.com/openai/whisper/)

## Features

Current release (v1.5.0) supports following whisper models:

- [openai/whisper](https://github.com/openai/whisper)@[v20231117](https://github.com/openai/whisper/releases/tag/v20231117)
- [SYSTRAN/faster-whisper](https://github.com/SYSTRAN/faster-whisper)@[v1.0.3](https://github.com/SYSTRAN/faster-whisper/releases/tag/1.0.3)

## Quick Usage

### CPU

```sh
docker run -d -p 9000:9000 -e ASR_MODEL=base -e ASR_ENGINE=openai_whisper ghcr.io/crimeisdown/whisper-asr-webservice:latest
```

### GPU

```sh
docker run -d --gpus all -p 9000:9000 -e ASR_MODEL=base -e ASR_ENGINE=openai_whisper ghcr.io/crimeisdown/whisper-asr-webservice:latest-gpu
```

for more information:

- [Documentation/Run](https://ahmetoner.com/whisper-asr-webservice/run/)

## Documentation

Explore the documentation by clicking [here](https://ahmetoner.com/whisper-asr-webservice).

## Credits

- This software uses libraries from the [FFmpeg](http://ffmpeg.org) project under the [LGPLv2.1](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)
