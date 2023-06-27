function clipped_int_beat = clipping(int_beat,clipp_threshold_real,clipp_threshold_imag )

int_beat_real = real(int_beat);
int_beat_imag = imag(int_beat);
int_beat_real(int_beat_real >= clipp_threshold_real ) = clipp_threshold_real;
int_beat_real(int_beat_real <= -clipp_threshold_real ) = -clipp_threshold_real;
int_beat_imag(int_beat_imag >= clipp_threshold_imag ) = clipp_threshold_imag;
int_beat_imag(int_beat_imag <= -clipp_threshold_imag ) = -clipp_threshold_imag;
clipped_int_beat = complex(int_beat_real,int_beat_imag);

