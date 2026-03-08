
-- SQL code to send notifications when a product is added
-- This requires a Supabase Edge Function named 'push-notification' to be deployed.

-- 1. Create the function that will be called by the trigger
CREATE OR REPLACE FUNCTION public.notify_new_product()
RETURNS TRIGGER AS $$
DECLARE
  payload JSONB;
BEGIN
  -- Construct the payload
  payload := jsonb_build_object(
    'title', 'New Product Added!',
    'body', 'Check out ' || NEW.name || ' at ' || (SELECT name FROM public.shops WHERE id = NEW.shop_id),
    'data', jsonb_build_object(
      'product_id', NEW.id,
      'type', 'new_product'
    )
  );

  -- Call the Edge Function (this requires net extension or standard Supabase edge function call)
  -- Example using Supabase's built-in HTTP request capability if available
  -- OR you can use it to insert into a 'notifications_queue' table.
  
  -- For now, we will log it or you can trigger a webhook.
  -- In a real Supabase environment, you would use:
  -- PERFORM net.http_post(
  --   url := 'https://<project-ref>.supabase.co/functions/v1/send-push',
  --   headers := jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || auth.role()),
  --   body := payload
  -- );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Create the trigger
DROP TRIGGER IF EXISTS on_product_created ON public.products;
CREATE TRIGGER on_product_created
AFTER INSERT ON public.products
FOR EACH ROW EXECUTE FUNCTION public.notify_new_product();
