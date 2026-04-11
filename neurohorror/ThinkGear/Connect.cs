using Godot;
using libStreamSDK;
using System;

public partial class Connect : Button
{
	private int connectionID;
	private double lastRead = 0;
	private double delay = 0.25;

	private static Color COLOR_CONNECTED = new Color(0, 1, 0);
	private static Color COLOR_NOT_CONNECTED = new Color(1, 0, 0);
	private static Color COLOR_POOR_SIGNAL = new Color(1, 0.5f, 0);

	private const int STATE_NOT_CONNECTED = -2;
	private const int STATE_POOR_SIGNAL = -1;
	private const int STATE_CONNECTED = 0;

	[Export]
	public LineEdit COM;
	[Export]
	public ColorRect ConnectionState;

	public int connectionState = -2;
	public int attention = 0;
	public int meditation = 0;

    public override void _Pressed()
	{
		lastRead = 0;
		string comPortName = "\\\\.\\"+COM.Text;
		if (connectionState!=STATE_NOT_CONNECTED) { 
			NativeThinkgear.TG_Disconnect(connectionID);
			ConnectionState.Color = COLOR_NOT_CONNECTED;
			connectionState = STATE_NOT_CONNECTED;
			Text = "Connect";
			return;
		}
		int errCode = NativeThinkgear.TG_Connect(connectionID,
						  comPortName,
						  NativeThinkgear.Baudrate.TG_BAUD_57600,
						  NativeThinkgear.SerialDataFormat.TG_STREAM_PACKETS);
		if (errCode < 0)
		{
			ConnectionState.Color = COLOR_NOT_CONNECTED;
			connectionState = STATE_NOT_CONNECTED;
			GD.Print("ERROR: TG_Connect() returned: " + errCode);
			return;
		}
		connectionState = STATE_POOR_SIGNAL;
		Text = "Disconnect";
		//NativeThinkgear.TG_EnableAutoRead(connectionID, 1);
		ConnectionState.Color = COLOR_POOR_SIGNAL;
	}

	public override void _Ready()
	{
		NativeThinkgear thinkgear = new NativeThinkgear();
		GD.Print("Version: " + NativeThinkgear.TG_GetVersion());
		connectionID = NativeThinkgear.TG_GetNewConnectionId();
		GD.Print("Connection ID: " + connectionID);
		/*string comPortName = "\\\\.\\COM8";
		int errCode = NativeThinkgear.TG_Connect(connectionID,
						  comPortName,
						  NativeThinkgear.Baudrate.TG_BAUD_57600,
						  NativeThinkgear.SerialDataFormat.TG_STREAM_PACKETS);
		if (errCode < 0)
		{
			GD.Print("ERROR: TG_Connect() returned: " + errCode);
			return;
		}
		NativeThinkgear.TG_EnableAutoRead(connectionID, 1);*/
	}
	public override void _Process(double delta)
	{
		if (connectionState==STATE_NOT_CONNECTED)
		{
			return;
		}
		lastRead += delta;
		if (lastRead > delay)
		{
			lastRead = 0;
			int errCode = NativeThinkgear.TG_ReadPackets(connectionID, -1);
			if (errCode < 10)
			{
				delay += 0.005;
			}else if (errCode > 200)
			{
				delay -= 0.005;
			}
				
				//GD.Print("TG_ReadPackets returned: " + errCode+" "+delay);	
			if (errCode < 0)
			{
				ConnectionState.Color = COLOR_NOT_CONNECTED;
				connectionState = STATE_POOR_SIGNAL;
				return;
			}
			attention = (int)NativeThinkgear.TG_GetValue(connectionID, NativeThinkgear.DataType.TG_DATA_ATTENTION);
			meditation = (int)NativeThinkgear.TG_GetValue(connectionID, NativeThinkgear.DataType.TG_DATA_MEDITATION);
			int strenght = (int)NativeThinkgear.TG_GetValue(connectionID, NativeThinkgear.DataType.TG_DATA_POOR_SIGNAL);
			if (strenght > 0 && connectionState!=STATE_POOR_SIGNAL)
			{
				connectionState = STATE_POOR_SIGNAL;
				ConnectionState.Color = COLOR_POOR_SIGNAL;
			}
			else if (strenght == 0 && connectionState==STATE_POOR_SIGNAL)
			{
				connectionState = STATE_CONNECTED;
				ConnectionState.Color = COLOR_CONNECTED;
			}
			//GD.Print("Attention value: : " + attention);
			//GD.Print("Meditation value: : " + meditation);
			//GD.Print("Strenght: : " + strenght);
		}
	}
}
