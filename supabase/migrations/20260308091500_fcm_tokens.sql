
-- Create fcm_tokens table
CREATE TABLE public.fcm_tokens (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  device_info JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Users can manage their own tokens
CREATE POLICY "Users can manage their own fcm tokens" 
ON public.fcm_tokens 
FOR ALL 
USING (auth.uid() = user_id);

-- Trigger to update updated_at
CREATE TRIGGER update_fcm_tokens_updated_at 
BEFORE UPDATE ON public.fcm_tokens 
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
