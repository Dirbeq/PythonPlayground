export MODEL_NAME=ft_iam
export SAVE_PATH=/path/to/save/${MODEL_NAME}
export LOG_DIR=log_${MODEL_NAME}
export DATA=.../data/IAM
mkdir ${LOG_DIR}
export BSZ=8
export valid_BSZ=16

CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 python -m torch.distributed.launch --nproc_per_node=8 \
  $(which fairseq-train) \
  --data-type STR --user-dir ./ --task text_recognition --input-size 384 \
  --arch trocr_large \
  --seed 1111 --optimizer adam --lr 2e-05 --lr-scheduler inverse_sqrt \
  --warmup-init-lr 1e-8 --warmup-updates 500 --weight-decay 0.0001 --log-format tqdm \
  --log-interval 10 --batch-size ${BSZ} --batch-size-valid ${valid_BSZ} --save-dir ${SAVE_PATH} \
  --tensorboard-logdir ${LOG_DIR} --max-epoch 300 --patience 20 --ddp-backend legacy_ddp \
  --num-workers 8 --preprocess DA2 --update-freq 1 \
  --bpe gpt2 --decoder-pretrained roberta2 \
  --finetune-from-model /path/to/model --fp16 \
  ${DATA}
