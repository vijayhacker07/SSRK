
USE [PaymentTrackingManagementDb]
GO
/****** Object:  Schema [dashboard]    Script Date: 14-07-2022 11:53:22 ******/
CREATE SCHEMA [dashboard]
GO
/****** Object:  Schema [datafilter]    Script Date: 14-07-2022 11:53:22 ******/
CREATE SCHEMA [datafilter]
GO
/****** Object:  Schema [HangFire]    Script Date: 14-07-2022 11:53:22 ******/
CREATE SCHEMA [HangFire]
GO
/****** Object:  Schema [issuetracker]    Script Date: 14-07-2022 11:53:22 ******/
CREATE SCHEMA [issuetracker]
GO
/****** Object:  Schema [Done]    Script Date: 14-07-2022 11:53:22 ******/
CREATE SCHEMA [Done]
GO
/****** Object:  Schema [UserMode]    Script Date: 14-07-2022 11:53:22 ******/
CREATE SCHEMA [UserMode]
GO
/****** Object:  UserDefinedTableType [dbo].[id_list]    Script Date: 14-07-2022 11:53:22 ******/
CREATE TYPE [dbo].[id_list] AS TABLE(
	[id] [nvarchar](50) NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
/****** Object:  UserDefinedFunction [dbo].[UDF_GetUserTransactionLocationId]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[UDF_GetUserTransactionLocationId]
(
	-- Add the parameters for the function here
	@locationId nvarchar(50)
)
RETURNS nvarchar(50)
AS
BEGIN

	-- Return the result of the function
	declare @result nvarchar(50)=(select p.Id from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id join Locations p on l.OrganizationId=p.OrganizationId join LocationTypes plt on p.LocationTypeId=plt.Id where plt.IsAdminLevel=1 and p.LeftExtent <=l.LeftExtent and p.RightExtent >= l.RightExtent and l.Id=@locationId);
	RETURN @result;
END

GO
/****** Object:  UserDefinedFunction [dbo].[UDF_GetEndDateFromPeriodicity]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		K.V.S.Ramakrinshna
-- Create date: 2023-03-12
-- Description:	Gets the start date based on end date and periodicity/granularity
-- =============================================
CREATE   FUNCTION [dbo].[UDF_GetEndDateFromPeriodicity]
(
	-- Add the parameters for the function here
	@value int
)
RETURNS datetime
AS
BEGIN
declare @endDateTime datetime = dateadd(minute,330,getutcdate());
	-- Return the result of the function
	RETURN case
            when @value > 400 then DATEADD(second, -1, DATEDIFF(day, 0, DATEADD(year, DATEDIFF(year, 0, @endDateTime) + 1, -1)) + 1)
            when @value > 300 then DATEADD(second, -1, DATEDIFF(day, 0, eomonth(@endDateTime)) + 1)
            when @value > 200 then DATEADD(second, -1, DATEDIFF(day, 0, @endDateTime) + 1)
            --when @value > 100 then DATEADD(Hour, DATEDIFF(hour, 0, @endDateTime) + 1, -1)
            else @endDateTime
        end
END
GO
/****** Object:  UserDefinedFunction [dbo].[UDF_ParseStartDateFromPeriodicityGranularity]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		K.V.S.Ramkrishna
-- Create date: 2023-03-12
-- Description:	Gets the start date based on end date and periodicity/granularity
-- =============================================
CREATE   FUNCTION [dbo].[UDF_ParseStartDateFromPeriodicityGranularity]
(
	-- Add the parameters for the function here
	@value int, @endDateTime datetime
)
RETURNS datetime
AS
BEGIN

	-- Return the result of the function
	RETURN case
            when @value > 400 then dateadd(second,1,DateAdd(Year, -(@value-400), @endDateTime))
            when @value > 300 then dateadd(second,1,DateAdd(Month, -(@value-300), @endDateTime))
            when @value > 200 then dateadd(second,1,DateAdd(Day, -(@value-200), @endDateTime))
            when @value > 100 then DateAdd(Hour, -(@value-100), @endDateTime)
            else DateAdd(Minute,-@value, @endDateTime)
        end
END
GO
/****** Object:  UserDefinedFunction [dbo].[UDF_RoundOffDateTimeByGranularity]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		K.V.S.Ramakrishna
-- Create date: 2023-03-12
-- Description:	Round off the date based on granularity
-- =============================================
CREATE   FUNCTION [dbo].[UDF_RoundOffDateTimeByGranularity]
(
	-- Add the parameters for the function here
	@value int, @dateTime datetime
)
RETURNS datetime
AS
BEGIN

	-- Return the result of the function
	RETURN case
            when @value > 400 then cast(cast(@dateTime as date) as datetime)
            when @value > 300 then cast(cast(@dateTime as date) as datetime)
            when @value > 200 then DATEADD(MINUTE, ROUND(DATEDIFF(MINUTE, 0, @dateTime) / 60.0, 0) * 60, 0)
            when @value > 100 then DATEADD(MINUTE, ROUND(DATEDIFF(MINUTE, 0, @dateTime) / 15.0, 0) * 15, 0)
            else @dateTime
        end
END
GO
/****** Object:  Table [dbo].[UserClaims]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserClaims](
	[UserId] [nvarchar](50) NOT NULL,
	[transactionId] [nvarchar](50) NOT NULL,
	[ClaimType] [nvarchar](50) NOT NULL,
	[ClaimValue] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_UserClaims] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[transactionId] ASC,
	[ClaimType] ASC,
	[ClaimValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 12-03-2023 10:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locations](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Code] [nvarchar](50) NULL,
	[IsActive] [bit] NOT NULL,
	[Password] [nvarchar](50) NULL,
	[Email] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](15) NULL,
	[Address] [nvarchar](200) NULL,
	[BillingAddress] [nvarchar](200) NULL,
	[ImageUrl] [nvarchar](512) NULL,
	[LeftExtent] [int] NOT NULL,
	[RightExtent] [int] NOT NULL,
	[ParentLocationId] [nvarchar](50) NULL,
	[OrganizationId] [nvarchar](50) NULL,
	[LocationTypeId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[FinalResultsBy] [DateTime2](7) NULL,
 CONSTRAINT [PK_Locations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[UDF_GetAccessibleLocations]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		K V S Ramakrishna
-- Create date: 12-03-2023
-- Description:	Getting Access to the locations
-- =============================================
CREATE   FUNCTION [dbo].[UDF_GetAccessibleLocations] 
(	
	@userId nvarchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
	select distinct l.Id from Locations l join Locations ul on ul.OrganizationId=l.OrganizationId and l.LeftExtent >= ul.LeftExtent and l.RightExtent <=ul.RightExtent
left join UserClaims uc on uc.ClaimType='Location' and uc.UserId=@userId and uc.ClaimValue=l.Id
where @userId='BUILTIN_USER_SUPER_ADMIN' or (l.IsActive=1 and UC.ClaimValue IS NOT NULL)
)
GO
/****** Object:  UserDefinedFunction [dbo].[UDF_GetAllLocationsUnderParentId]    Script Date: 12-03-2023 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		K V S Ramakrishna
-- Create date: 12-03-2023
-- Description:	Getting all location in under the parent
-- =============================================
CREATE   FUNCTION [dbo].[UDF_GetAllLocationsUnderParentId] 
(	
	@parentLocationId nvarchar(50), @userId nvarchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
	select loc_root.Id as RootId, loc_root.name as RootName, l.Id as LocationId, l.Name as LocationName, l.LeftExtent, l.RightExtent, l.ParentLocationId, l.LocationTypeId from
Locations loc_root join Locations l on loc_root.OrganizationId=l.OrganizationId and loc_root.LeftExtent <= l.LeftExtent and loc_root.RightExtent >= l.RightExtent and loc_root.OrganizationId=l.OrganizationId
--left join UserClaims uc on uc.ClaimType='Location' and uc.UserId=@userId and uc.ClaimValue=l.Id
where loc_root.ParentLocationId=@parentLocationId or (loc_root.LeftExtent=loc_root.RightExtent-1 and loc_root.Id=@parentLocationId)
--and (@userId='BUILTIN_USER_SUPER_ADMIN' or (l.IsActive=1 and UC.ClaimValue IS NOT NULL))
)


GO
/****** Object:  Table [dbo].[LocationTypes]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LocationTypes](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Level] [int] NOT NULL,
	[IsAdminLevel] [bit] NOT NULL,
	[OrganizationId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_LocationTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[UDF_GetSubLocationsByIP]    Script Date: 12-03-2023 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		K V S Ramakrishna
-- Create date: 12-03-2023
-- Description:	Getting the transaction locaion by IP"Internet Protocol"
-- =============================================
CREATE   FUNCTION [dbo].[UDF_GetSubLocationsByIP] 
(	
	@locationId nvarchar(50), @tenantId nvarchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
	select distinct l.Id, l.LeftExtent, l.RightExtent from Locations l
join Locations pl on pl.OrganizationId=l.OrganizationId and pl.LeftExtent <= l.LeftExtent and pl.RightExtent >= l.RightExtent
join LocationTypes lt on pl.LocationTypeId=lt.Id
where pl.Id=isnull(@locationId, @tenantId)
)
GO
/****** Object:  Table [dashboard].[DashboardLayouts]    Script Date: 12-03-2023 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dashboard].[DashboardLayouts](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](50) NULL,
	[LayoutData] [nvarchar](max) NULL,
	[TenantId] [nvarchar](50) NULL,
	[DashboardIndex] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[UserId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_DashboardLayouts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dashboard].[ReportDataSources]    Script Date: 12-03-2023 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dashboard].[ReportDataSources](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[DataSourceGroup] [nvarchar](50) NULL,
	[BaseQueryForTable] [nvarchar](max) NULL,
	[BaseQueryForKpi] [nvarchar](max) NULL,
	[Fields] [nvarchar](max) NULL,
 CONSTRAINT [PK_ReportDataSources] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dashboard].[WidgetFields]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dashboard].[WidgetFields](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[WidgetMetadataId] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[HeaderText] [nvarchar](50) NULL,
	[ChartType] [nvarchar](50) NULL,
	[Color] [nvarchar](50) NULL,
	[PieColors] [nvarchar](50) NULL,
	[DataType] [nvarchar](50) NULL,
	[ValueSuffix] [nvarchar](50) NULL,
	[PlotOption] [nvarchar](50) NULL,
 CONSTRAINT [PK_WidgetFields] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dashboard].[WidgetGroups]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dashboard].[WidgetGroups](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[LocationId] [nvarchar](50) NULL,
	[LayoutId] [nvarchar](50) NULL,
	[Periodicity] [int] NOT NULL,
	[Granularity] [int] NOT NULL,
	[CustomStartDate] [datetime2](7) NULL,
	[CustomEndDate] [datetime2](7) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_WidgetGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dashboard].[WidgetMetadata]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dashboard].[WidgetMetadata](
	[Id] [nvarchar](50) NOT NULL,
	[ComponentId] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Icon] [nvarchar](30) NOT NULL,
	[Description] [nvarchar](256) NULL,
	[WidgetType] [nvarchar](20) NOT NULL,
	[DataSourceIdOld] [nvarchar](50) NULL,
	[DataSourceId] [nvarchar](50) NULL,
	[DateTimeFilterField] [nvarchar](50) NULL,
	[KpiField] [nvarchar](50) NULL,
	[DrilldownUrl] [nvarchar](500) NULL,
	[Unit] [nvarchar](10) NULL,
	[ChartConfig] [nvarchar](max) NULL,
	[KpiConfig] [nvarchar](max) NULL,
	[DatasourceParameters] [nvarchar](max) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_WidgetMetadata] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dashboard].[Widgets]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dashboard].[Widgets](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Icon] [nvarchar](50) NULL,
	[DataUrl] [nvarchar](256) NULL,
	[WidgetDefinitionId] [nvarchar](100) NULL,
	[PositionX] [int] NOT NULL,
	[PositionY] [int] NOT NULL,
	[RowSpan] [int] NOT NULL,
	[ColumnSpan] [int] NOT NULL,
	[WidgetView] [nvarchar](50) NULL,
	[WidgetGroupId] [nvarchar](50) NULL,
	[WidgetData] [nvarchar](max) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_Widgets] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [datafilter].[FilterGroups]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [datafilter].[FilterGroups](
	[Id] [nvarchar](50) NOT NULL,
	[Condition] [int] NOT NULL,
	[FilterGroupId] [nvarchar](50) NULL,
 CONSTRAINT [PK_FilterGroups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [datafilter].[FilterItems]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [datafilter].[FilterItems](
	[Id] [nvarchar](50) NOT NULL,
	[FieldId] [nvarchar](50) NULL,
	[FilterGroupId] [nvarchar](50) NOT NULL,
	[FilterOperator] [nvarchar](50) NULL,
	[PresetValue] [int] NOT NULL,
	[TextValue] [nvarchar](50) NULL,
	[NumericValue] [decimal](18, 5) NULL,
	[BooleanValue] [bit] NULL,
	[DateTimeValue] [datetime2](7) NULL,
 CONSTRAINT [PK_FilterItems] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Organizations]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organizations](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Code] [nvarchar](5) NOT NULL,
	[Address] [nvarchar](200) NULL,
	[Email] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](15) NULL,
	[LogoUrl] [nvarchar](50) NULL,
	[Website] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_Organizations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[RoleLevel] [int] NOT NULL,
	[IsBuiltin] [bit] NOT NULL,
	[TenantId] [nvarchar](50) NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tokens]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tokens](
	[Id] [nvarchar](50) NOT NULL,
	[RefreshToken] [nvarchar](256) NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[ExpiresOn] [datetime2](7) NOT NULL,
	[BrowserFingerprint] [nvarchar](512) NULL,
	[TenantId] [nvarchar](50) NULL,
	[EmployeeId] [nvarchar](50) NULL,
	[UserId] [nvarchar](50) NULL,
 CONSTRAINT [PK_Tokens] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRoles]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoles](
	[UserId] [nvarchar](50) NOT NULL,
	[RoleId] [nvarchar](50) NOT NULL,
	[TenantId] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC,
	[TenantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [nvarchar](50) NOT NULL,
	[UserName] [nvarchar](20) NOT NULL,
	[PasswordHash] [nvarchar](256) NULL,
	[DisplayName] [nvarchar](100) NOT NULL,
	[PhoneNumber] [nvarchar](15) NULL,
	[Email] [nvarchar](50) NULL,
	[AvatarUrl] [nvarchar](256) NULL,
	[DefaultTenantId] [nvarchar](50) NULL,
	[IsBuiltin] [bit] NOT NULL,
	[PhoneNumberVerified] [bit] NOT NULL,
	[PhoneNumberVerificationHash] [nvarchar](256) NULL,
	[PhoneNumberVerificationExpiryUtc] [datetime2](7) NULL,
	[EmailVerified] [bit] NOT NULL,
	[EmailVerificationHash] [nvarchar](256) NULL,
	[EmailVerificationExpiryUtc] [datetime2](7) NULL,
	[PasswordChangeVerificationHash] [nvarchar](256) NULL,
	[PasswordChangeVerificationExpiryUtc] [datetime2](7) NULL,
	[LastPasswordChangedUtc] [datetime2](7) NULL,
	[TemproaryLockoutUtc] [datetime2](7) NULL,
	[IsPermanentLockOut] [bit] NOT NULL,
	[FailedLoginAttempts] [int] NOT NULL,
	[EmployeeId] [nvarchar](50) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[AggregatedCounter]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[AggregatedCounter](
	[Key] [nvarchar](100) NOT NULL,
	[Value] [bigint] NOT NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_CounterAggregated] PRIMARY KEY CLUSTERED 
(
	[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Counter]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Counter](
	[Key] [nvarchar](100) NOT NULL,
	[Value] [int] NOT NULL,
	[ExpireAt] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Hash]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Hash](
	[Key] [nvarchar](100) NOT NULL,
	[Field] [nvarchar](100) NOT NULL,
	[Value] [nvarchar](max) NULL,
	[ExpireAt] [datetime2](7) NULL,
 CONSTRAINT [PK_HangFire_Hash] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Field] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Job]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Job](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[StateId] [bigint] NULL,
	[StateName] [nvarchar](20) NULL,
	[InvocationData] [nvarchar](max) NOT NULL,
	[Arguments] [nvarchar](max) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_Job] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[JobParameter]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[JobParameter](
	[JobId] [bigint] NOT NULL,
	[Name] [nvarchar](40) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_HangFire_JobParameter] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[JobQueue]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[JobQueue](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[JobId] [bigint] NOT NULL,
	[Queue] [nvarchar](50) NOT NULL,
	[FetchedAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_JobQueue] PRIMARY KEY CLUSTERED 
(
	[Queue] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[List]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[List](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Key] [nvarchar](100) NOT NULL,
	[Value] [nvarchar](max) NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_List] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Schema]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Schema](
	[Version] [int] NOT NULL,
 CONSTRAINT [PK_HangFire_Schema] PRIMARY KEY CLUSTERED 
(
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Server]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Server](
	[Id] [nvarchar](200) NOT NULL,
	[Data] [nvarchar](max) NULL,
	[LastHeartbeat] [datetime] NOT NULL,
 CONSTRAINT [PK_HangFire_Server] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Set]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Set](
	[Key] [nvarchar](100) NOT NULL,
	[Score] [float] NOT NULL,
	[Value] [nvarchar](256) NOT NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_Set] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Value] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[State]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[State](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[JobId] [bigint] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Reason] [nvarchar](100) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[Data] [nvarchar](max) NULL,
 CONSTRAINT [PK_HangFire_State] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [issuetracker].[Comments]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [issuetracker].[Comments](
	[Id] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[ScreenshotUrl] [nvarchar](256) NULL,
	[CommentedById] [nvarchar](50) NULL,
	[CommentedOn] [datetime2](7) NOT NULL,
	[ParentCommentId] [nvarchar](50) NULL,
	[IssueId] [nvarchar](50) NULL,
	[TenantId] [nvarchar](50) NULL,
 CONSTRAINT [PK_Comments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [issuetracker].[Issues]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [issuetracker].[Issues](
	[Id] [nvarchar](50) NOT NULL,
	[TicketNumber] [nvarchar](20) NULL,
	[Title] [nvarchar](100) NULL,
	[Description] [nvarchar](500) NULL,
	[Label] [nvarchar](30) NULL,
	[ScreenshotUrl] [nvarchar](256) NULL,
	[ReportedById] [nvarchar](50) NULL,
	[ReportedOn] [datetime2](7) NOT NULL,
	[LastStatusChangedById] [nvarchar](50) NULL,
	[LastStatusChangedOn] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[DuplicateIssueId] [nvarchar](50) NULL,
	[TenantId] [nvarchar](50) NULL,
 CONSTRAINT [PK_Issues] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [issuetracker].[IssueTags]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [issuetracker].[IssueTags](
	[IssueId] [nvarchar](50) NOT NULL,
	[TagId] [int] NOT NULL,
	[TagOwnerId] [nvarchar](50) NULL,
 CONSTRAINT [PK_IssueTags] PRIMARY KEY CLUSTERED 
(
	[IssueId] ASC,
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [issuetracker].[Tags]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [issuetracker].[Tags](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[AppFeatures]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[AppFeatures](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Icon] [nvarchar](20) NULL,
	[IconProvider] [int] NOT NULL,
	[Route] [nvarchar](50) NULL,
	[Description] [nvarchar](250) NULL,
	[DynamicNodePath] [nvarchar](50) NULL,
	[IsMainMenu] [bit] NOT NULL,
	[HasWrite] [bit] NOT NULL,
	[HasApprove] [bit] NOT NULL,
	[BadgePath] [nvarchar](50) NULL,
	[TenantRequired] [bit] NOT NULL,
	[IsAccessLocked] [bit] NOT NULL,
	[Ordinal] [int] NOT NULL,
	[IsBuiltin] [bit] NOT NULL,
	[IsAccessibleToEveryone] [bit] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_AppFeatures] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[AppModules]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[AppModules](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](30) NULL,
	[Description] [nvarchar](250) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_AppModules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[Attachments]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[Attachments](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[DownloadUrl] [nvarchar](256) NULL,
	[ThumbnailUrl] [nvarchar](256) NULL,
	[ParentId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_Attachments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[CaptchaStore]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[CaptchaStore](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BrowserFingerprint] [nvarchar](50) NULL,
	[CaptchaHash] [nvarchar](50) NULL,
 CONSTRAINT [PK_CaptchaStore] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[EmailConfigurations]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[EmailConfigurations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SMTPServer] [nvarchar](50) NULL,
	[SenderEmailAddress] [nvarchar](50) NULL,
	[SenderName] [nvarchar](50) NULL,
	[UserName] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NULL,
	[SMTPPort] [int] NOT NULL,
	[EnableSSL] [bit] NOT NULL,
	[SecureSocketOptions] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[OrganizationId] [nvarchar](50) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_EmailConfigurations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[EmailTemplates]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[EmailTemplates](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](500) NULL,
	[TemplateBody] [nvarchar](max) NULL,
	[TenantId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_EmailTemplates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [keabis].[ExternalApplications]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[ExternalApplications](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[ApiKey] [nvarchar](256) NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTill] [datetime2](7) NOT NULL,
	[TenantId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_ExternalApplications] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[FirebaseTokens]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[FirebaseTokens](
	[DeviceId] [nvarchar](50) NOT NULL,
	[UserId] [nvarchar](50) NOT NULL,
	[RegistrationId] [nvarchar](256) NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_FirebaseTokens] PRIMARY KEY CLUSTERED 
(
	[DeviceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[OTPRequestLogs]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[OTPRequestLogs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](50) NULL,
	[OTPRequestFor] [nvarchar](50) NULL,
	[RequestDateTime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_OTPRequestLogs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[PasswordChangeLogs]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[PasswordChangeLogs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](50) NULL,
	[ChangedOn] [datetime2](7) NOT NULL,
	[PasswordHash] [nvarchar](256) NULL,
 CONSTRAINT [PK_PasswordChangeLogs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[ReferenceNumberStore]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[ReferenceNumberStore](
	[TenantId] [nvarchar](50) NOT NULL,
	[ModelName] [nvarchar](50) NOT NULL,
	[ReferenceNumber] [bigint] NOT NULL,
 CONSTRAINT [PK_ReferenceNumberStore] PRIMARY KEY CLUSTERED 
(
	[TenantId] ASC,
	[ModelName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [keabis].[RolePrivileges]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [keabis].[RolePrivileges](
	[FeatureId] [nvarchar](50) NOT NULL,
	[RoleId] [nvarchar](50) NOT NULL,
	[CanRead] [bit] NOT NULL,
	[CanWrite] [bit] NOT NULL,
	[CanApprove] [bit] NOT NULL,
	[IsBuiltin] [bit] NOT NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[TenantId] [nvarchar](50) NULL,
 CONSTRAINT [PK_RolePrivileges] PRIMARY KEY CLUSTERED 
(
	[FeatureId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[AssignFieldLocation]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[AssignFieldLocation](
	[Id] [nvarchar](50) NOT NULL,
	[DynamicFieldId] [nvarchar](50) NULL,
	[PageId] [int] NOT NULL,
	[SeqNo] [int] NOT NULL,
	[SourceId] [int] NOT NULL,
	[TenantId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_AssignFieldLocation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[DynamicField]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[DynamicField](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[DisplayText] [nvarchar](1000) NULL,
	[IsRequired] [bit] NOT NULL,
	[DataType] [nvarchar](50) NULL,
	[AccessId] [int] NOT NULL,
	[TenantId] [nvarchar](50) NULL,
	[Type] [nvarchar](50) NULL,
	[DisplayId] [int] NOT NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_DynamicField] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[DynamicFieldOption]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[DynamicFieldOption](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](1000) NULL,
	[AssignFieldLocationId] [nvarchar](50) NULL,
	[DynamicFieldId] [nvarchar](50) NULL,
	[ImageURL] [nvarchar](200) NULL,
	[IsSourceConnected] [bit] NOT NULL,
	[SourceTypeId] [nvarchar](50) NULL,
	[TenantId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_DynamicFieldOption] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[EmployeeIdCard]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[EmployeeIdCard](
	[Id] [nvarchar](50) NOT NULL,
	[EmployeeId] [nvarchar](200) NULL,
	[Name] [nvarchar](200) NULL,
	[EmailId] [nvarchar](200) NULL,
	[MobileNo] [nvarchar](200) NULL,
	[ValidFrom] [datetime2](7) NULL,
	[ValidTo] [datetime2](7) NULL,
	[Data1] [nvarchar](200) NULL,
	[Data2] [nvarchar](200) NULL,
	[Data3] [nvarchar](200) NULL,
	[TenantId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_EmployeeIdCard] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[LocationDetails]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[LocationDetails](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Title] [nvarchar](500) NULL,
	[LogoUrl] [nvarchar](50) NULL,
	[BackgroundUrl] [nvarchar](50) NULL,
	[IsOTPRequired] [bit] NOT NULL,
	[TenantId] [nvarchar](50) NOT NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
	[isDocumentUrl] [bit] NOT NULL,
	[isPhotoUrl] [bit] NOT NULL,
 CONSTRAINT [PK_LocationDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[MasteField]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[MasteField](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[DisplayText] [nvarchar](1000) NULL,
	[IsRequired] [bit] NOT NULL,
	[DataType] [nvarchar](50) NULL,
	[AccessId] [int] NOT NULL,
	[TenantId] [nvarchar](50) NULL,
	[Type] [nvarchar](50) NULL,
	[DisplayId] [int] NOT NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
	[SourceId] [int] NOT NULL,
 CONSTRAINT [PK_MasteField] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[SiteVisitor]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[SiteVisitor](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[PhoneNumber] [nvarchar](50) NULL,
	[Email] [nvarchar](50) NULL,
	[Organization] [nvarchar](50) NULL,
	[UserId] [nvarchar](50) NULL,
	[EmployeeName] [nvarchar](50) NULL,
	[PurposeId] [nvarchar](50) NULL,
	[PhotoImageUrl] [nvarchar](512) NULL,
	[DocumentImageUrl] [nvarchar](512) NULL,
	[SignatureImageUrl] [nvarchar](512) NULL,
	[VisitingDateTime] [datetime2](7) NULL,
	[CheckInDateTime] [datetime2](7) NULL,
	[CheckOutDateTime] [datetime2](7) NULL,
	[IsCheckedOut] [bit] NOT NULL,
	[StatusId] [int] NOT NULL,
	[StatusMessage] [nvarchar](50) NULL,
	[Other] [nvarchar](512) NULL,
	[IsInvited] [bit] NULL,
	[IsApproved] [int] NOT NULL,
	[ApprovedId] [nvarchar](50) NULL,
	[ApprovedOn] [datetime2](7) NULL,
	[ClientId] [nvarchar](50) NULL,
	[IsNotAccectable] [bit] NOT NULL,
	[VisitorCode] [nvarchar](50) NULL,
	[TenantId] [nvarchar](50) NOT NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_SiteVisitor] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[SourceData]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[SourceData](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](1000) NULL,
	[SourceTypeId] [nvarchar](50) NULL,
	[Description] [nvarchar](1000) NULL,
	[IsTriggerNotification] [bit] NOT NULL,
	[ImageUrl] [nvarchar](200) NULL,
	[ColorCode] [nvarchar](50) NULL,
	[Data1] [nvarchar](1000) NULL,
	[Data2] [nvarchar](1000) NULL,
	[Data3] [nvarchar](1000) NULL,
	[TenantId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
	[SeqNo] [int] NOT NULL,
	[Data4] [nvarchar](1000) NULL,
	[Data5] [nvarchar](1000) NULL,
	[Data6] [nvarchar](1000) NULL,
 CONSTRAINT [PK_SourceData] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[SourceType]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[SourceType](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](500) NULL,
	[TenantId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
	[DisplayId] [int] NOT NULL,
 CONSTRAINT [PK_SourceType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[VisitorDataCollection]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[VisitorDataCollection](
	[Id] [nvarchar](50) NOT NULL,
	[FieldValue] [nvarchar](1000) NULL,
	[AssignFieldLocationId] [nvarchar](50) NULL,
	[DynamicFieldId] [nvarchar](50) NULL,
	[TenantId] [nvarchar](50) NULL,
	[Description] [nvarchar](1000) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
	[VisitorId] [nvarchar](50) NULL,
	[DynamicFieldOptionId] [nvarchar](50) NULL,
	[IsTriggerNotification] [bit] NOT NULL,
 CONSTRAINT [PK_VisitorDataCollection] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[VisitorHeader]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[VisitorHeader](
	[Id] [nvarchar](50) NOT NULL,
	[PageId] [int] NOT NULL,
	[PageTitle] [nvarchar](1000) NULL,
	[Header1] [nvarchar](1000) NULL,
	[Header2] [nvarchar](1000) NULL,
	[Header3] [nvarchar](1000) NULL,
	[TenantId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
	[SourceId] [int] NOT NULL,
 CONSTRAINT [PK_VisitorHeader] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Visitor].[VisitorMenu]    Script Date: 14-07-2022 11:53:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Visitor].[VisitorMenu](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Title] [nvarchar](500) NULL,
	[MenuUrl] [nvarchar](50) NULL,
	[ColorCode] [nvarchar](50) NULL,
	[TextColor] [nvarchar](50) NULL,
	[TenantId] [nvarchar](50) NULL,
	[CreatedById] [nvarchar](50) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ModifiedById] [nvarchar](50) NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_VisitorMenu] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dashboard].[DashboardLayouts] ([Id], [Name], [Description], [LayoutData], [TenantId], [DashboardIndex], [IsActive], [UserId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'01744769669776331', N'Default', N'Default layout auto generated', NULL, N'LOC01738857706660028', NULL, 1, N'BUILTIN_USER_SUPER_ADMIN', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T09:49:26.9966667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T09:49:26.9966667' AS DateTime2), NULL)
GO
INSERT [dashboard].[WidgetGroups] ([Id], [Name], [LocationId], [LayoutId], [Periodicity], [Granularity], [CustomStartDate], [CustomEndDate], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn]) VALUES (N'WGP01744769668419057', N'Test', N'LOC01738857706660028', N'01744769669776331', 203, 0, NULL, NULL, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T09:49:26.8433333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T09:49:26.8433333' AS DateTime2))
GO
INSERT [dashboard].[WidgetGroups] ([Id], [Name], [LocationId], [LayoutId], [Periodicity], [Granularity], [CustomStartDate], [CustomEndDate], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn]) VALUES (N'WGP01744805428342687', N'Untitled', N'LOC01738857706660028', N'01744769669776331', 301, 0, NULL, NULL, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:49:02.8333333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:49:02.8333333' AS DateTime2))
GO
INSERT [dashboard].[WidgetGroups] ([Id], [Name], [LocationId], [LayoutId], [Periodicity], [Granularity], [CustomStartDate], [CustomEndDate], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn]) VALUES (N'WGP01744806051209348', N'Untitled', N'LOC01738857706660028', N'01744769669776331', 301, 0, NULL, NULL, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:50:05.1200000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:50:05.1200000' AS DateTime2))
GO
INSERT [dashboard].[Widgets] ([Id], [Name], [Icon], [DataUrl], [WidgetDefinitionId], [PositionX], [PositionY], [RowSpan], [ColumnSpan], [WidgetView], [WidgetGroupId], [WidgetData], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn]) VALUES (N'WGT01744788837690164', N'Total Feedbacks Received', N'question_answer', N'dashboard/kpi/textdata', N'textdata', 0, 0, 1, 2, N'kpi', N'WGP01744769668419057', N'{"aggregate":"Total"}', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:21:23.7700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:21:23.7700000' AS DateTime2))
GO
INSERT [dashboard].[Widgets] ([Id], [Name], [Icon], [DataUrl], [WidgetDefinitionId], [PositionX], [PositionY], [RowSpan], [ColumnSpan], [WidgetView], [WidgetGroupId], [WidgetData], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn]) VALUES (N'WGT01744805476649734', N'Total Feedbacks Received', N'question_answer', N'dashboard/kpi/testdata', N'testdata', 0, 0, 1, 2, N'kpi', N'WGP01744805428342687', N'{"aggregate":"Avg"}', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:49:07.6666667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:49:07.6666667' AS DateTime2))
GO
INSERT [dashboard].[Widgets] ([Id], [Name], [Icon], [DataUrl], [WidgetDefinitionId], [PositionX], [PositionY], [RowSpan], [ColumnSpan], [WidgetView], [WidgetGroupId], [WidgetData], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn]) VALUES (N'WGT01744806094065749', N'Total Feedbacks Received', N'question_answer', N'dashboard/kpi/testdata', N'testdata', 0, 0, 1, 2, N'kpi', N'WGP01744806051209348', N'{"aggregate":"Total"}', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:50:09.4066667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T10:50:09.4066667' AS DateTime2))
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20220706101204_InitialCreate', N'3.1.15')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20220706122625_addvisitormodule', N'3.1.15')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20220706124657_updatesourcedata', N'3.1.15')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20220707114706_addemployeecard', N'3.1.15')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20220707133718_updatevisitordata', N'3.1.15')
GO
INSERT [dbo].[__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES (N'20220711075909_update_modeldata', N'3.1.15')
GO
INSERT [dbo].[Locations] ([Id], [Name], [Code], [IsActive], [ContactPersonName], [Email], [PhoneNumber], [Address], [BillingAddress], [ImageUrl], [LeftExtent], [RightExtent], [ParentLocationId], [OrganizationId], [LocationTypeId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn]) VALUES (N'LOC01738857706660028', N'Keabis Bangalore', N'KEABIS-01', 1, N'Deepak', N'deepak@keabis.com', N'9886147699', N'Bangalore', N'Bangalore', NULL, 1, 2, N'ORG01738739262512779', N'ORG01738739262512779', N'66B425A79102498398B5FF53A1D0A21D', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:36:10.4200000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:36:10.4200000' AS DateTime2))
GO
INSERT [dbo].[Locations] ([Id], [Name], [Code], [IsActive], [ContactPersonName], [Email], [PhoneNumber], [Address], [BillingAddress], [ImageUrl], [LeftExtent], [RightExtent], [ParentLocationId], [OrganizationId], [LocationTypeId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn]) VALUES (N'ORG01738739262512779', N'KEABIS TECH PVT LTD', NULL, 1, N'Deepak', N'deepak@keabis.com', N'9886147699', N'Bangalore', N'Bangalore', NULL, 0, 3, NULL, N'ORG01738739262512779', N'LTP01738739262513539', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T10:18:46.1233333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T10:18:46.1233333' AS DateTime2))
GO
INSERT [dbo].[LocationTypes] ([Id], [Name], [Level], [IsAdminLevel], [OrganizationId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'66B425A79102498398B5FF53A1D0A21D', N'Site', 1, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:35:37.6366667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:35:37.6366667' AS DateTime2), NULL)
GO
INSERT [dbo].[LocationTypes] ([Id], [Name], [Level], [IsAdminLevel], [OrganizationId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'LTP01738739262513539', N'KEABIS TECH PVT LTD', 0, 0, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T10:18:46.1233333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T10:18:46.1233333' AS DateTime2), NULL)
GO
INSERT [dbo].[Organizations] ([Id], [Name], [Code], [Address], [Email], [PhoneNumber], [LogoUrl], [Website], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'ORG01738739262512779', N'KEABIS TECH PVT LTD', N'K0001', N'Bangalore', N'deepak@keabis.com', N'9886147699', NULL, NULL, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T10:18:46.1233333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T10:18:46.1233333' AS DateTime2), NULL)
GO
INSERT [dbo].[Roles] ([Id], [Name], [RoleLevel], [IsBuiltin], [TenantId]) VALUES (N'BUILTIN_ROLE_ADMIN', N'Admin', 2, 1, NULL)
GO
INSERT [dbo].[Roles] ([Id], [Name], [RoleLevel], [IsBuiltin], [TenantId]) VALUES (N'BUILTIN_ROLE_EMPLOYEE', N'Employee', -1, 1, NULL)
GO
INSERT [dbo].[Roles] ([Id], [Name], [RoleLevel], [IsBuiltin], [TenantId]) VALUES (N'BUILTIN_ROLE_OPERATOR', N'Operator', 4, 1, NULL)
GO
INSERT [dbo].[Roles] ([Id], [Name], [RoleLevel], [IsBuiltin], [TenantId]) VALUES (N'BUILTIN_ROLE_ORG_MANAGER', N'OrgManager', 1, 1, NULL)
GO
INSERT [dbo].[Roles] ([Id], [Name], [RoleLevel], [IsBuiltin], [TenantId]) VALUES (N'BUILTIN_ROLE_SUPERVISOR', N'Supervisor', 3, 1, NULL)
GO
INSERT [dbo].[Roles] ([Id], [Name], [RoleLevel], [IsBuiltin], [TenantId]) VALUES (N'BUILTIN_USER_SUPER_ADMIN', N'SuperAdmin', 0, 1, NULL)
GO
INSERT [dbo].[Roles] ([Id], [Name], [RoleLevel], [IsBuiltin], [TenantId]) VALUES (N'RLE01738858543733715', N'Floor Manager', 3, 0, N'ORG01738739262512779')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738738828279909', N'bT15L/2aDDprmPzgplOkXBivGbDSvG+CXctqVh9fXf8=', CAST(N'2022-07-06T10:18:02.4000000' AS DateTime2), CAST(N'2022-07-06T10:23:02.4000000' AS DateTime2), NULL, NULL, NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738739475582920', N'+v8BkVy23Uxq32gUtKEFiZIJ6r8f+b5bo4lAZVOsu7I=', CAST(N'2022-07-06T10:19:07.1266667' AS DateTime2), CAST(N'2022-07-06T10:27:37.1966667' AS DateTime2), NULL, N'ORG01738739262512779', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738853962610462', N'/aF9U+0ETptP7DHANNbsaBvwSJKiTRDn7+CG/SZi5ic=', CAST(N'2022-07-06T13:29:55.9600000' AS DateTime2), CAST(N'2022-07-06T13:34:55.9600000' AS DateTime2), NULL, NULL, NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738857143084735', N'M5St8tt/1vFMxTJZOWXBJmX9rLA3xYPBL6QHHryz0q4=', CAST(N'2022-07-06T13:35:14.0100000' AS DateTime2), CAST(N'2022-07-06T13:40:21.5666667' AS DateTime2), NULL, N'ORG01738739262512779', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738861167700075', N'WwRGvr7HuC+b/tphWEp1GLhQKwEDkh7XdSB5i+H5o9c=', CAST(N'2022-07-06T13:41:56.4733333' AS DateTime2), CAST(N'2022-07-06T13:47:03.9933333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738861631238282', N'LB6vz7gLs6VhVwH7ygb29KTkzYq/vIA5dnjCYZNOywA=', CAST(N'2022-07-06T13:42:42.8266667' AS DateTime2), CAST(N'2022-07-06T13:47:42.8266667' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738874830457638', N'm/qxVgwpW/exqyMzZ+K45rkRZm9vev3Bn0Scw4TdnVE=', CAST(N'2022-07-06T14:04:43.0666667' AS DateTime2), CAST(N'2022-07-06T14:09:43.0666667' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738875014198976', N'ZoDJllQm6M5bF24pjbBCq2vPS1CrsWx3BkgFKib9NUI=', CAST(N'2022-07-06T14:05:01.4366667' AS DateTime2), CAST(N'2022-07-06T14:11:50.6566667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738876341327640', N'PqHE55GEvKQ2Dsmx71GDo3Vqlz9OLHDYsEkoFIcq7O4=', CAST(N'2022-07-06T14:07:14.1466667' AS DateTime2), CAST(N'2022-07-06T14:12:14.1466667' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738876572644268', N'at1pbM9XIfrvOP7OOKYODaZyWBoYiG8h5uBm7mIH97s=', CAST(N'2022-07-06T14:07:37.2733333' AS DateTime2), CAST(N'2022-07-06T14:12:37.2733333' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01738876960961294', N'OrIe6J+Lej7SO8O+RUuaUaRTaLU8FFPRu7iodWmSsyw=', CAST(N'2022-07-06T14:08:16.1066667' AS DateTime2), CAST(N'2022-07-06T14:13:16.1066667' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01739517910544224', N'aqdGN3nVK0mPPvzDJeNbgDK4OD2llnyLVrICzRiDvVU=', CAST(N'2022-07-07T07:56:31.0933333' AS DateTime2), CAST(N'2022-07-07T12:40:22.8800000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01739715430921722', N'XDcX1BQlnakZIU5Zn/2i7AlsDlq61JCUOaxg3G4F52U=', CAST(N'2022-07-07T13:25:43.1400000' AS DateTime2), CAST(N'2022-07-11T13:42:34.2400000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01739724966093465', N'2hwGxNbIfqOfHIFZaKbsHjSiCjLT/A2P/rbbih4DLW8=', CAST(N'2022-07-07T13:41:36.7333333' AS DateTime2), CAST(N'2022-07-07T13:46:36.7333333' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01739726697563714', N'9qKGuhYN5PuJExVu8RjPAduapZ0Fe7EIcuMZtxwYVZQ=', CAST(N'2022-07-07T13:44:29.7766667' AS DateTime2), CAST(N'2022-07-07T13:49:29.7766667' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01739730886688332', N'FT1g6IhRWvkPDJBxP3/9FJKFyFD3SqRYjEhqt2YhIA0=', CAST(N'2022-07-07T13:51:28.6800000' AS DateTime2), CAST(N'2022-07-07T13:56:28.6800000' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01739732483899488', N'gJe7LM/bIqQUpl8bS4pSLLpv3y0oFKxAqCzVtbHdqh8=', CAST(N'2022-07-07T13:54:08.5233333' AS DateTime2), CAST(N'2022-07-07T13:59:08.5233333' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740347721522212', N'Cc0nuj4PDn3wrk4GoBYi2LTu2Z/+197W0MX/2scC8Y0=', CAST(N'2022-07-08T06:59:31.7200000' AS DateTime2), CAST(N'2022-07-08T07:04:31.7200000' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740350684423717', N'tAYM8TV4WWEoCTLAANGGZJRs3ysLyHRghTI0vi2CO6k=', CAST(N'2022-07-08T07:04:28.0100000' AS DateTime2), CAST(N'2022-07-08T07:09:33.5700000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740350900013534', N'f4Jdr3TzaxgyHbIAtEPemTUTUWq8T8SZrjld8mSMno0=', CAST(N'2022-07-08T07:04:49.5666667' AS DateTime2), CAST(N'2022-07-08T07:09:49.5666667' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740352792976200', N'nvuPEk7OxWCawSxsBf0QUXc9epFAojrnyTRpZsm8fN4=', CAST(N'2022-07-08T07:07:58.8700000' AS DateTime2), CAST(N'2022-07-08T07:13:56.4633333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740360684128261', N'WkCj+/6M62Ex7krnXHb/9d8fgyKbea8vuyDXEly5Ve0=', CAST(N'2022-07-08T07:21:07.9933333' AS DateTime2), CAST(N'2022-07-08T07:26:07.9933333' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740361197650905', N'ci8kfe3EuNQUfEQbPlqy73MFa14+qbyIVVjkRkTIn1k=', CAST(N'2022-07-08T07:21:59.3433333' AS DateTime2), CAST(N'2022-07-08T07:27:34.7100000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740364826599706', N'0OwDQlk1KFZ+qJeFv2erNoB4ADN5SexMeRd8RjOYzFk=', CAST(N'2022-07-08T07:28:02.2400000' AS DateTime2), CAST(N'2022-07-08T07:33:32.2266667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740382381184629', N'II0aFh91hcZEn+6Vwl6wKUJuNHJlY1smbHzmWijlYb4=', CAST(N'2022-07-08T07:57:17.7133333' AS DateTime2), CAST(N'2022-07-08T08:02:42.2933333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740526638439686', N'uuJbWjVRMeaBIhDsnShmRAmppsEmXKp1y2Ruol3cLIQ=', CAST(N'2022-07-08T11:57:43.5900000' AS DateTime2), CAST(N'2022-07-08T12:02:58.8000000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740530271427760', N'xjDDeVe+/2yHPFdIhb6LIpnjQOLwKDzvMMvG6V2Qy2I=', CAST(N'2022-07-08T12:03:46.8900000' AS DateTime2), CAST(N'2022-07-08T12:25:52.6166667' AS DateTime2), NULL, NULL, NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740540653049556', N'U0OoRgpa2b+NGDWHslXv5HKx0Vfu16aZdRc9PBMnIPY=', CAST(N'2022-07-08T12:21:05.0666667' AS DateTime2), CAST(N'2022-07-08T12:26:06.6133333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740540770396383', N'qdgjkT0dfqHPegk33Re/ougPYB4RbiZ2eKFDuGQK9Aw=', CAST(N'2022-07-08T12:21:16.7966667' AS DateTime2), CAST(N'2022-07-08T12:26:16.7966667' AS DateTime2), NULL, NULL, NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740541808570491', N'wJh4eIyUkH4kF6bQuRI8/1A75G4jgHEjlmLOaeQafxg=', CAST(N'2022-07-08T12:23:00.6133333' AS DateTime2), CAST(N'2022-07-08T12:28:02.5800000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740541952378700', N'rroDPAepMh8lBr3n2ZlkT0aphOCs86CmNNzTB3Ng+Fc=', CAST(N'2022-07-08T12:23:14.9966667' AS DateTime2), CAST(N'2022-07-08T12:29:40.1533333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740543181117008', N'XJIUmJls83KAta6rG/hWSQvOXBW9jiJnLuXmY9SUPXg=', CAST(N'2022-07-08T12:25:17.8700000' AS DateTime2), CAST(N'2022-07-08T12:30:25.5033333' AS DateTime2), NULL, N'ORG01738739262512779', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740544661679943', N'Wqt5cPO1+n/yK+P7+4QN3qWqC8wzknFB1sMnRg/jC2s=', CAST(N'2022-07-08T12:27:45.9300000' AS DateTime2), CAST(N'2022-07-08T12:44:02.7466667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01740571330091410', N'o9Vcio5RcKIGHMrHUVBzSpgs+19KlVSdxib0x8r8ejM=', CAST(N'2022-07-08T13:12:12.7966667' AS DateTime2), CAST(N'2022-07-08T13:49:49.5533333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01742939256499406', N'/ABx87sm/4HX0YYRo1hSyRrMOYxT7Z/67qwCZqO6fCE=', CAST(N'2022-07-11T06:58:45.6833333' AS DateTime2), CAST(N'2022-07-11T07:03:50.7433333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743098821345739', N'LVSfV36P8LO4n1jtYaeHUxEVA2XsfB0X4SS6DXD4blg=', CAST(N'2022-07-11T11:24:42.8666667' AS DateTime2), CAST(N'2022-07-11T13:37:20.6800000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743178940161436', N'5MUrS3cWnHO4lAF7J/2nKfDAoxH8QtVdsHyBsEmQL7o=', CAST(N'2022-07-11T13:38:14.0266667' AS DateTime2), CAST(N'2022-07-12T06:12:04.7866667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743772302154430', N'MlcnDSVQ9FnLDlp7oynmtkvlRnz9K6EvcRMRHUZo4fc=', CAST(N'2022-07-12T06:07:10.2200000' AS DateTime2), CAST(N'2022-07-12T07:07:45.5133333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743778619296590', N'AHH0t2xPzICWbyAswAUJzKVR/i4/zYe6hyOcgFLs8Ds=', CAST(N'2022-07-12T06:17:41.3600000' AS DateTime2), CAST(N'2022-07-12T06:22:43.7633333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743798054184047', N'GVv5I+eWpQ4vTosuxzjCXBVh9hOiJ9BlnOePiV4Ahm4=', CAST(N'2022-07-12T06:50:04.8666667' AS DateTime2), CAST(N'2022-07-12T07:17:16.1766667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743829022767215', N'XzV9tgJ2FBm9Nr9zpFWhpkHFhzPB3fQD/RifJyzcvJA=', CAST(N'2022-07-12T07:41:41.7566667' AS DateTime2), CAST(N'2022-07-12T08:19:24.0366667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743836775652249', N'w4kMMHxrm1YxGVF7D4+mkEyZyf03dOManpHStQn5IR0=', CAST(N'2022-07-12T07:54:37.5700000' AS DateTime2), CAST(N'2022-07-12T08:52:39.7300000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743841552811163', N'MlnqIE32EeWCjcVrP1LrMf1i0ZHrHTCvRfXSwJoHw0s=', CAST(N'2022-07-12T08:02:34.7766667' AS DateTime2), CAST(N'2022-07-12T08:08:03.1233333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743847010833360', N'S4Z42BKrd7fuR+wS52oCt0y1o3b0Zjq3DtHzevoBfB8=', CAST(N'2022-07-12T08:11:41.0933333' AS DateTime2), CAST(N'2022-07-12T08:16:42.7533333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743847705691423', N'yOmo+DSzmP3z/lXHZ2iXShuimBldm/QK7RmkfWK3LqA=', CAST(N'2022-07-12T08:12:50.5733333' AS DateTime2), CAST(N'2022-07-12T09:20:17.4966667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743857305322340', N'zJC8CgoTuTziNe8mNk/YP3adhvBi+PWniaWPvCdATOY=', CAST(N'2022-07-12T08:28:50.5433333' AS DateTime2), CAST(N'2022-07-12T08:33:50.5433333' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743858246211937', N'RT3SXv7SzBbEJlqMzP9m0k2iTly/Xq6JcUL4p1XSPSs=', CAST(N'2022-07-12T08:30:24.6333333' AS DateTime2), CAST(N'2022-07-12T08:35:24.6333333' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743860896629588', N'0d7jZuIOH/GPgUoJsvmJ7EZTPVKxLKvQzRggfzs2Ib4=', CAST(N'2022-07-12T08:34:49.6700000' AS DateTime2), CAST(N'2022-07-12T08:48:00.2200000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743865875413641', N'/0wds7wsvv+Kr5qKBPhZMGWSMVbIFfq2/3+7YApYnt0=', CAST(N'2022-07-12T08:43:07.5500000' AS DateTime2), CAST(N'2022-07-12T09:01:34.3800000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743867496769899', N'oq74wSau7sMB4H5FezK4XO+4cZQZVzvVvOyoLGzCRS0=', CAST(N'2022-07-12T08:45:49.1900000' AS DateTime2), CAST(N'2022-07-12T09:03:11.0966667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743874257625742', N'vV5LaH20Lvp4meeijdFU75DA1g9YW8Uu1lo2W2Q2+js=', CAST(N'2022-07-12T08:57:05.7700000' AS DateTime2), CAST(N'2022-07-12T09:02:05.7700000' AS DateTime2), NULL, NULL, NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743874569741598', N'W70/pYvN77yGYCeP8WTurxHqxdeS2V+c8uyyQABTZfU=', CAST(N'2022-07-12T08:57:36.9833333' AS DateTime2), CAST(N'2022-07-12T09:18:44.7233333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743875098037101', N'zsNt/eOuJPK5BQKfuBs6xVL2W1/+rQhbqqv7wplDKFY=', CAST(N'2022-07-12T08:58:29.3300000' AS DateTime2), CAST(N'2022-07-12T09:04:02.3700000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743884298728108', N'qcUuTPlgnsbqnTUsu7AhGlQTd+TRmkfqLsmD430dyOU=', CAST(N'2022-07-12T09:13:49.8833333' AS DateTime2), CAST(N'2022-07-13T06:17:31.1433333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743904280411823', N'msFmAlxQ36DXq4JPxHaV3672ERzUXGEEmv/HG/BJvI0=', CAST(N'2022-07-12T09:47:07.5966667' AS DateTime2), CAST(N'2022-07-12T09:52:38.9833333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743937294078461', N'GR7JJX+/fSnV/ygUf5fKcV4V6hliXNAB9r9UNhpn0QQ=', CAST(N'2022-07-12T10:42:08.9966667' AS DateTime2), CAST(N'2022-07-12T10:47:34.0300000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743944159257522', N'hesrKLxxM9tqyH70rzmhlHGFRrm8a2NStGzmZ2rhwH8=', CAST(N'2022-07-12T10:53:35.5200000' AS DateTime2), CAST(N'2022-07-12T11:00:41.1600000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01743947628591803', N'Br9tu9PHvwj1eQva1PhWHAw9wq2UTdhYimmvnhb148Q=', CAST(N'2022-07-12T10:59:22.4533333' AS DateTime2), CAST(N'2022-07-12T11:04:44.6466667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744049231659209', N'hi3TMJN9Txiw+6H+mn7np6bqP6X6JvV54Nd5WKoOsf8=', CAST(N'2022-07-12T13:48:42.8633333' AS DateTime2), CAST(N'2022-07-13T07:54:17.4000000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744049368925346', N'nBYf5/RVmhrlpduA2yy0MVWnWPjyBaI8pz8vIgZNBrI=', CAST(N'2022-07-12T13:48:56.5800000' AS DateTime2), CAST(N'2022-07-12T13:53:58.4333333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744049499828824', N'UK7s4I3JHHXPFTviJ3u4k3Bhud7nZmlX8oq6/r6tCO8=', CAST(N'2022-07-12T13:49:09.6766667' AS DateTime2), CAST(N'2022-07-12T13:54:09.6766667' AS DateTime2), NULL, NULL, NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744049846965432', N'xMVXpAZ6GqR7k//X8CJF/lSsdMHTMSgAq+uPNk7stD0=', CAST(N'2022-07-12T13:49:44.3900000' AS DateTime2), CAST(N'2022-07-12T13:54:46.2100000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744064425991152', N'4dzc2fe8EG/wLTit9BrTNzWXDTTt/aTxMoIFdE8jeLw=', CAST(N'2022-07-12T14:14:02.3166667' AS DateTime2), CAST(N'2022-07-12T14:19:33.6600000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744075823996778', N'HD5ZyuftBeJxDp9pRBfolzUUfw0Qukn/WMHPdOMQ4W0=', CAST(N'2022-07-12T14:33:02.4066667' AS DateTime2), CAST(N'2022-07-12T14:43:53.4766667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744086582913729', N'0Ne6bcXGFswveTBWiFTdFlSIzlqidRumoHnKdi8R3KE=', CAST(N'2022-07-12T14:50:58.3033333' AS DateTime2), CAST(N'2022-07-12T14:56:01.4566667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744607475455097', N'zzPSCE105/GW/smijOE6rUIiqJNkVFf6k8b4APEBG8o=', CAST(N'2022-07-13T05:19:07.5566667' AS DateTime2), CAST(N'2022-07-13T05:24:14.9566667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744607775849246', N'Rj/58OXX/oe9GZGh7/bLtmDaszYw0/yO+uSJtfIv62c=', CAST(N'2022-07-13T05:19:37.5933333' AS DateTime2), CAST(N'2022-07-13T05:24:38.7266667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744666753667198', N'wI3+sMVAZfsrTMZjMP3AOHdNDGF+YjuCIwN7y/gU6O4=', CAST(N'2022-07-13T06:57:54.5433333' AS DateTime2), CAST(N'2022-07-13T07:03:28.4600000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744673551239128', N'8AjWlCMSuDyx7EgIbX8vdKRgk0yXOh7wABU+3x7niEA=', CAST(N'2022-07-13T07:09:14.3033333' AS DateTime2), CAST(N'2022-07-13T07:14:37.4833333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744675898275448', N'uXg7lxxiHCydkTSb6sE2NDB+Q5V279+LDHzC98L3ca4=', CAST(N'2022-07-13T07:13:09.0133333' AS DateTime2), CAST(N'2022-07-13T07:18:33.1866667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744687210938708', N'RvIMOe1w1QZlyfHV9Ig8y56P3wworCAmzEJ95zXPrE4=', CAST(N'2022-07-13T07:32:01.1000000' AS DateTime2), CAST(N'2022-07-13T07:42:05.8533333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744699638090231', N'Y0DQ0w1X62BQWbhF/o1o8u0E5F0XVZYbJAVEv4cbqt0=', CAST(N'2022-07-13T07:52:43.0200000' AS DateTime2), CAST(N'2022-07-13T07:58:14.3833333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744706626082884', N'NZhuxfe0yFGZQNW9HBO/fmygQsC0H2A1E56bXrgLjpE=', CAST(N'2022-07-13T08:04:21.8200000' AS DateTime2), CAST(N'2022-07-13T08:09:43.6600000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744714802635614', N'wx+BhRSXsRnRfP/Gl9oceDHUZMzD5Rrj6qpRKFDML5U=', CAST(N'2022-07-13T08:17:59.4866667' AS DateTime2), CAST(N'2022-07-13T08:23:21.4200000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744718384733862', N'FWwNL1a+0raGfN4Yutp1LjRokwiJANx2VnI+lYFMaio=', CAST(N'2022-07-13T08:23:58.4866667' AS DateTime2), CAST(N'2022-07-13T08:29:05.1700000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744765776224028', N'h8ZkCxSu+VLn6rIvbfm2Zbnkbxw5Zs9m+FbexoU7TM0=', CAST(N'2022-07-13T09:42:57.6366667' AS DateTime2), CAST(N'2022-07-13T09:54:08.2766667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744786889473998', N'y54VSu5kNaEtpnzfYCGT/nEjLGFM65wwRUn5ZlhJ1Ew=', CAST(N'2022-07-13T10:18:08.5300000' AS DateTime2), CAST(N'2022-07-13T10:48:44.7833333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744802388078631', N'fVX/tUVe5r/3g4LktQ8v6BCmGnFzCDz4bO2hLZ88mPM=', CAST(N'2022-07-13T10:43:58.4000000' AS DateTime2), CAST(N'2022-07-13T10:54:02.7266667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744833130836735', N'n71Jfbds8NEw3yjBJv7U8MJZlUem8o2psaCMSV8+S6I=', CAST(N'2022-07-13T11:35:13.0900000' AS DateTime2), CAST(N'2022-07-14T06:12:56.6100000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744842061557953', N'Zy8SMJVBG+pM8DjtJkwgihprf/qdCYYl89/xlPxYjRw=', CAST(N'2022-07-13T11:50:06.1666667' AS DateTime2), CAST(N'2022-07-13T12:14:49.7833333' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'BUILTIN_USER_SUPER_ADMIN')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744849644612162', N'Wh42PplKGUpf1aIP5AEpXuXEv0vPzG3bcVH9gQ7GBx8=', CAST(N'2022-07-13T12:02:44.4900000' AS DateTime2), CAST(N'2022-07-13T12:07:48.9066667' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744867329558404', N'jPNtGmgFPDlziBvUbrpbbB1xT3Z4OVJ2MIjnd8BLEsA=', CAST(N'2022-07-13T12:32:12.6166667' AS DateTime2), CAST(N'2022-07-13T12:37:36.5800000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[Tokens] ([Id], [RefreshToken], [CreatedOn], [ExpiresOn], [BrowserFingerprint], [TenantId], [EmployeeId], [UserId]) VALUES (N'01744951339530461', N'fzTPGvp/1mDoCPgBN7OXIRCCW+cimZJLGZzbjzQkA4Q=', CAST(N'2022-07-13T14:52:13.9633333' AS DateTime2), CAST(N'2022-07-13T15:09:07.3100000' AS DateTime2), NULL, N'LOC01738857706660028', NULL, N'USR01738859499395145')
GO
INSERT [dbo].[UserClaims] ([UserId], [ClaimType], [ClaimValue]) VALUES (N'USR01738739262513526', N'Location', N'LOC01738857706660028')
GO
INSERT [dbo].[UserClaims] ([UserId], [ClaimType], [ClaimValue]) VALUES (N'USR01738739262513526', N'Location', N'ORG01738739262512779')
GO
INSERT [dbo].[UserClaims] ([UserId], [ClaimType], [ClaimValue]) VALUES (N'USR01738859499395145', N'Location', N'LOC01738857706660028')
GO
INSERT [dbo].[UserRoles] ([UserId], [RoleId], [TenantId]) VALUES (N'USR01738739262513526', N'BUILTIN_ROLE_ADMIN', N'LOC01738857706660028')
GO
INSERT [dbo].[UserRoles] ([UserId], [RoleId], [TenantId]) VALUES (N'USR01738859499395145', N'BUILTIN_ROLE_OPERATOR', N'LOC01738857706660028')
GO
INSERT [dbo].[UserRoles] ([UserId], [RoleId], [TenantId]) VALUES (N'USR01738739262513526', N'BUILTIN_ROLE_ORG_MANAGER', N'ORG01738739262512779')
GO
INSERT [dbo].[UserRoles] ([UserId], [RoleId], [TenantId]) VALUES (N'BUILTIN_USER_SUPER_ADMIN', N'BUILTIN_USER_SUPER_ADMIN', N'All')
GO
INSERT [dbo].[Users] ([Id], [UserName], [PasswordHash], [DisplayName], [PhoneNumber], [Email], [AvatarUrl], [DefaultTenantId], [IsBuiltin], [PhoneNumberVerified], [PhoneNumberVerificationHash], [PhoneNumberVerificationExpiryUtc], [EmailVerified], [EmailVerificationHash], [EmailVerificationExpiryUtc], [PasswordChangeVerificationHash], [PasswordChangeVerificationExpiryUtc], [LastPasswordChangedUtc], [TemproaryLockoutUtc], [IsPermanentLockOut], [FailedLoginAttempts], [EmployeeId], [IsDeleted]) VALUES (N'BUILTIN_SYSTEM', N'System', NULL, N'System', NULL, NULL, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [UserName], [PasswordHash], [DisplayName], [PhoneNumber], [Email], [AvatarUrl], [DefaultTenantId], [IsBuiltin], [PhoneNumberVerified], [PhoneNumberVerificationHash], [PhoneNumberVerificationExpiryUtc], [EmailVerified], [EmailVerificationHash], [EmailVerificationExpiryUtc], [PasswordChangeVerificationHash], [PasswordChangeVerificationExpiryUtc], [LastPasswordChangedUtc], [TemproaryLockoutUtc], [IsPermanentLockOut], [FailedLoginAttempts], [EmployeeId], [IsDeleted]) VALUES (N'BUILTIN_USER_SUPER_ADMIN', N'SuperAdmin', N'AQAAAAEAACcQAAAAEOK6jCXSCS15ux37cdmIWDwr6fxLr9ScMaksrpaJUlxS7u9I6LJCA12GmCkac+K/6A==', N'Super Admin', NULL, N'', NULL, NULL, 1, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [UserName], [PasswordHash], [DisplayName], [PhoneNumber], [Email], [AvatarUrl], [DefaultTenantId], [IsBuiltin], [PhoneNumberVerified], [PhoneNumberVerificationHash], [PhoneNumberVerificationExpiryUtc], [EmailVerified], [EmailVerificationHash], [EmailVerificationExpiryUtc], [PasswordChangeVerificationHash], [PasswordChangeVerificationExpiryUtc], [LastPasswordChangedUtc], [TemproaryLockoutUtc], [IsPermanentLockOut], [FailedLoginAttempts], [EmployeeId], [IsDeleted]) VALUES (N'USR01738739262513526', N'USR01738739262513526', NULL, N'Deepak', N'9886147699', N'deepak@keabis.com', NULL, N'ORG01738739262512779', 0, 0, NULL, NULL, 0, N'AQAAAAEAACcQAAAAENpjl7JbFYU5QIvLePFuOPSBQpXNjWuNeMK9+Nz5zl3O7mvUxeS4CU0buSLTMkTbWA==', CAST(N'2022-07-06T22:18:46.1233333' AS DateTime2), NULL, NULL, NULL, NULL, 0, 0, NULL, NULL)
GO
INSERT [dbo].[Users] ([Id], [UserName], [PasswordHash], [DisplayName], [PhoneNumber], [Email], [AvatarUrl], [DefaultTenantId], [IsBuiltin], [PhoneNumberVerified], [PhoneNumberVerificationHash], [PhoneNumberVerificationExpiryUtc], [EmailVerified], [EmailVerificationHash], [EmailVerificationExpiryUtc], [PasswordChangeVerificationHash], [PasswordChangeVerificationExpiryUtc], [LastPasswordChangedUtc], [TemproaryLockoutUtc], [IsPermanentLockOut], [FailedLoginAttempts], [EmployeeId], [IsDeleted]) VALUES (N'USR01738859499395145', N'keabisoperator', N'AQAAAAEAACcQAAAAEPke7aX/g68wCiaUds/J8RBPF7x7w9opm6PFGJq1yLbUTeSLvfSI4WZ6eY/qKwxUPg==', N'Operator', NULL, N'keabisoperator@yopmail.com', NULL, N'LOC01738857706660028', 0, 0, NULL, NULL, 1, NULL, CAST(N'2022-07-07T01:39:09.9400000' AS DateTime2), NULL, NULL, NULL, NULL, 0, 0, NULL, NULL)
GO
INSERT [HangFire].[AggregatedCounter] ([Key], [Value], [ExpireAt]) VALUES (N'stats:succeeded', 2, NULL)
GO
INSERT [HangFire].[AggregatedCounter] ([Key], [Value], [ExpireAt]) VALUES (N'stats:succeeded:2022-07-06', 2, CAST(N'2022-08-06T13:39:17.647' AS DateTime))
GO
INSERT [HangFire].[Schema] ([Version]) VALUES (7)
GO
INSERT [HangFire].[Server] ([Id], [Data], [LastHeartbeat]) VALUES (N'dw1sdwk0008bf:6264:3f12de55-b94d-4eab-9600-731e9bc4c880', N'{"WorkerCount":5,"Queues":["default"],"StartedAt":"2022-07-12T14:49:45.8416975Z"}', CAST(N'2022-07-14T06:23:00.880' AS DateTime))
GO
INSERT [HangFire].[Server] ([Id], [Data], [LastHeartbeat]) VALUES (N'dw1sdwk0008bf:6264:556bd5b0-24cb-4082-ba75-cb3066e34d19', N'{"WorkerCount":5,"Queues":["default"],"StartedAt":"2022-07-12T14:49:45.6650517Z"}', CAST(N'2022-07-14T06:23:01.067' AS DateTime))
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'APP_FEATURES', N'Features', N'extension', 0, N'/features', N'Create/manage application features', NULL, 0, 1, 0, NULL, 0, 1, 1, 1, NULL, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'ASSIGN_FIELD', N'Assign Location', N'article', 0, N'/Visitor/assign/create', NULL, NULL, 1, 1, 0, NULL, 1, 0, 0, 0, 0, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'DYNAMIC_FIELD', N'Visitor Field Master', N'article', 0, N'/dynamic/header', NULL, NULL, 1, 1, 0, NULL, 1, 0, -1, 0, 0, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'EMAILTEMPLATES', N'Email Templates', N'mail', 0, N'/emailtemplate', N'Manage email templates', NULL, 0, 1, 0, NULL, 1, 0, 5, 1, NULL, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'HOME', N'Dashboard', N'dashboard', 0, N'/home', N'Manage Location based on organizational hierarchy', NULL, 1, 1, 0, NULL, 1, 1, 3, 1, 1, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'LOCATION_MASTER', N'Location', N'my_location', 0, N'/location', N'Manage Location based on organizational hierarchy', NULL, 0, 1, 0, NULL, 1, 0, 2, 1, NULL, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'ORGANIZATION_MASTER', N'Organization', N'business', 0, N'/organization', N'Create/manage organizations', NULL, 0, 1, 0, NULL, 0, 1, 0, 1, NULL, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'PAGE_HEADER', N'Page Title', N'article', 0, N'/Page/header', NULL, NULL, 1, 1, 0, NULL, 1, 0, 0, 0, 0, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'SOURCE_DATA', N'Source Data', N'article', 0, N'/Source/header', NULL, NULL, 1, 1, 0, NULL, 1, 0, -1, 0, 0, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'USER_MASTER', N'User', N'account_circle', 0, N'/user', N'Manage user master and their roles and responsibilities', NULL, 1, 1, 0, NULL, 1, 0, 4, 1, NULL, NULL)
GO
INSERT [keabis].[AppFeatures] ([Id], [Name], [Icon], [IconProvider], [Route], [Description], [DynamicNodePath], [IsMainMenu], [HasWrite], [HasApprove], [BadgePath], [TenantRequired], [IsAccessLocked], [Ordinal], [IsBuiltin], [IsAccessibleToEveryone], [IsDeleted]) VALUES (N'VISITOR_LOCATION_DETAILS', N'Location Details', N'article', 0, N'/visitor/header', N'Location Details', NULL, 1, 1, 0, NULL, 1, 0, -1, 0, 0, NULL)
GO
INSERT [keabis].[ReferenceNumberStore] ([TenantId], [ModelName], [ReferenceNumber]) VALUES (N'Default', N'Organization', 1)
GO
INSERT [keabis].[RolePrivileges] ([FeatureId], [RoleId], [CanRead], [CanWrite], [CanApprove], [IsBuiltin], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [TenantId]) VALUES (N'EMAILTEMPLATES', N'RLE01738858543733715', 0, 0, 0, 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:37:34.8500000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:37:34.8500000' AS DateTime2), N'ORG01738739262512779')
GO
INSERT [keabis].[RolePrivileges] ([FeatureId], [RoleId], [CanRead], [CanWrite], [CanApprove], [IsBuiltin], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [TenantId]) VALUES (N'LOCATION_MASTER', N'BUILTIN_ROLE_ADMIN', 1, 1, 0, 1, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [keabis].[RolePrivileges] ([FeatureId], [RoleId], [CanRead], [CanWrite], [CanApprove], [IsBuiltin], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [TenantId]) VALUES (N'LOCATION_MASTER', N'BUILTIN_ROLE_ORG_MANAGER', 1, 1, 0, 1, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [keabis].[RolePrivileges] ([FeatureId], [RoleId], [CanRead], [CanWrite], [CanApprove], [IsBuiltin], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [TenantId]) VALUES (N'LOCATION_MASTER', N'RLE01738858543733715', 0, 0, 0, 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:37:34.8766667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:37:34.8766667' AS DateTime2), N'ORG01738739262512779')
GO
INSERT [keabis].[RolePrivileges] ([FeatureId], [RoleId], [CanRead], [CanWrite], [CanApprove], [IsBuiltin], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [TenantId]) VALUES (N'USER_MASTER', N'BUILTIN_ROLE_ADMIN', 1, 1, 0, 1, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [keabis].[RolePrivileges] ([FeatureId], [RoleId], [CanRead], [CanWrite], [CanApprove], [IsBuiltin], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [TenantId]) VALUES (N'USER_MASTER', N'BUILTIN_ROLE_ORG_MANAGER', 1, 1, 0, 1, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [keabis].[RolePrivileges] ([FeatureId], [RoleId], [CanRead], [CanWrite], [CanApprove], [IsBuiltin], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [TenantId]) VALUES (N'USER_MASTER', N'RLE01738858543733715', 0, 0, 0, 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:37:34.8933333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T13:37:34.8933333' AS DateTime2), N'ORG01738739262512779')
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'0A98C5E9-E9B8-4F3B-B55E-5B657E1956E0', N'C6F16AEA-3080-4ADC-81FF-D4A2D7C3DAFB', 1, 5, 2, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'1234B4AD-DA5E-4478-BFFD-7834471F1E9B', N'D03A6C40-E750-4FCD-B480-9BEBE8F9ED2E', 1, 8, 3, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'141C7799-98CE-4C2E-9801-1660F32E9343', N'948C77C7-3772-430A-86B9-A57FBE773AB0', 5, 1, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'27969C9F-F6CC-4BCB-977E-20796614663A', N'11832633-98CB-4912-AE55-8ABE2F53EE50', 2, 3, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'3B3580AD-486F-440B-A41E-DFCC0B27CF09', N'D89843BE-8965-4295-B39E-AFFEDF622196', 1, 5, 3, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'4750C6E1-1B3B-4294-87A0-526D615FDF45', N'9FC395FB-7587-4C7C-9E83-628943A0C68B', 3, 2, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'4DBD9D83-1029-4CE2-953B-11FA51D0FAAE', N'750E4001-8281-490A-95A3-7D2C57A4375F', 1, 6, 3, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'5157FDB6-B5EF-41A4-A38C-9CD03CF980AB', N'D7495D21-1577-46C0-990E-9F8C4F3462C8', 4, 1, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'562A488E-B74D-45FD-907A-060E93706629', N'F7C49CFA-1AD6-416A-9AC2-F68118AFE6B4', 4, 2, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'712D6521-82FB-4831-99E7-ED524EA16E00', N'D1D1DFCA-E54E-479F-A9A1-E488D697640E', 6, 1, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'760FC9E1-83A3-418E-BAF8-B33573E93E84', N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', 1, 2, 2, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'79AA480C-1805-4D70-9559-3D49057DA82C', N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', 1, 3, 3, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'80EEE650-8EFF-4575-85C1-882C26450989', N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', 1, 2, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'8DDE8281-FA1D-4DFC-8F07-0DC38EF15CAD', N'6A77A4BE-D225-452D-AE4A-0621A69094B5', 6, 2, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'902F6E91-E9B5-446E-81CC-13368BF15C52', N'7EE74742-624B-40D6-BAE0-479626768297', 3, 1, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'97139253-3EFA-4551-AFB2-5B037056FABC', N'5B2874EE-6457-4414-A8AC-845164CBEAAC', 1, 2, 3, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'972BA0A6-270B-445F-9A28-0324AC18AB5D', N'B7BC6A4F-A54A-49F9-838C-1A8147FC437C', 2, 4, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'9CD09A1E-A342-47FD-A428-0B1AB1D090CC', N'7D454E8A-5C6E-4ACA-A467-AB7AAC95395A', 2, 2, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'9DCD846D-500A-45D4-80E7-64F790B3F32F', N'7D454E8A-5C6E-4ACA-A467-AB7AAC95395A', 1, 5, 2, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'9E911EA1-7D25-4B91-BCC7-31968B3D657E', N'DEA84BA1-5903-45A6-A2A1-EA0F5DFA91F2', 6, 3, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'A038188F-A6B9-4535-9E9C-77D007CFB9BB', N'B7BC6A4F-A54A-49F9-838C-1A8147FC437C', 1, 6, 2, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'A5580E32-4129-4193-85A8-7E988B5D4C27', N'23BAC2C0-4009-49D9-956B-DF294538C2AF', 4, 3, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'A5732492-8D0E-4032-999A-2D4B2AD6CD61', N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', 1, 1, 2, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AACA1412-B333-405D-9963-3376F517C177', N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', 1, 3, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF001', N'DF001', 1, 1, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8366667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8366667' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF002', N'DF002', 1, 1, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8400000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8400000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF003', N'DF003', 1, 1, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8433333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8433333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF004', N'DF004', 2, 1, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8433333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8433333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF005', N'DF005', 2, 2, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8466667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8466667' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF006', N'DF006', 2, 3, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8466667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8466667' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF007', N'DF007', 2, 4, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8500000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8500000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF008', N'DF008', 3, 1, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8500000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8500000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF009', N'DF009', 3, 2, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8533333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8533333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF010', N'DF010', 3, 3, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8533333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8533333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF011', N'DF011', 4, 1, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8566667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8566667' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF012', N'DF012', 4, 2, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8566667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8566667' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF013', N'DF013', 4, 3, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8600000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8600000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF014', N'DF014', 5, 1, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8600000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8600000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF015', N'DF015', 5, 2, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8600000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8600000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF016', N'DF016', 5, 3, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8633333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8633333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF017', N'DF017', 6, 1, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8633333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8633333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF018', N'DF018', 6, 2, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8666667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8666667' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF019', N'DF019', 6, 3, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8666667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8666667' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF020', N'DF020', 7, 3, 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:22:47.8700000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF021', N'DF021', 1, 2, 3, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2066667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2066667' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF022', N'DF022', 1, 5, 3, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2100000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2100000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF023', N'DF023', 1, 6, 3, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2133333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2133333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF024', N'DF024', 1, 7, 3, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2133333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2133333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF025', N'DF025', 1, 8, 3, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2166667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:00:19.2166667' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF026', N'DF001', 1, 1, 3, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:55:17.7200000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:55:17.7200000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF027', N'DF002', 1, 3, 3, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:55:17.7233333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:55:17.7233333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF028', N'DF003', 1, 4, 3, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:55:17.7233333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:55:17.7233333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AF31C650-30E5-448A-86E5-8482815D7C9B', N'79776D76-5BED-42B3-9C5A-47D05346B0A0', 5, 3, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'B99918B8-8DBF-44D1-B421-D7B2C8C38DF7', N'9F14579F-B8C4-4E34-8644-CB25B69E8FD9', 7, 3, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'BA012C4F-DA81-4E8C-A02F-28AFC8B4D276', N'B200D9F2-B99B-4984-8B18-B756BBDF7A83', 1, 7, 3, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'CF27B9BF-CC5B-4710-B43B-1348E4931F2E', N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', 1, 4, 3, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'CFD7EBBB-929D-4B9D-A355-07571FA1653D', N'C6F16AEA-3080-4ADC-81FF-D4A2D7C3DAFB', 2, 1, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'D7874847-2784-4D1E-8F0E-8B950F5FFED9', N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', 1, 1, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DC7F29C2-D07E-484E-9893-DEF033378BC1', N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', 1, 3, 2, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'E7724FE9-471A-4E95-9EA7-37652653B2E4', N'8665EA12-6B7B-43C1-A68C-A5050888E403', 3, 3, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'EAD5CB0B-B04E-49F4-9522-763EB42ADE09', N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', 1, 1, 3, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[AssignFieldLocation] ([Id], [DynamicFieldId], [PageId], [SeqNo], [SourceId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'EC06F76D-0544-41AA-BD65-F4CC9F0A84FE', N'2233E952-16CC-497C-BF17-CEA17419673A', 5, 2, 1, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'11832633-98CB-4912-AE55-8ABE2F53EE50', N'Whom To meet', N'Whom To meet', 1, N'dropdown', 2, N'LOC01738857706660028', N'dropdown', 6, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'2233E952-16CC-497C-BF17-CEA17419673A', N'', N'Cough/ Dry cough', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'23BAC2C0-4009-49D9-956B-DF294538C2AF', N'', N'Visit any health facility in home country after travel?', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', N'Name', N'Name', 1, N'string', 1, N'LOC01738857706660028', N'textbox', 1, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'5B2874EE-6457-4414-A8AC-845164CBEAAC', N'Employee Id', N'Employee Id', 1, N'string', 1, N'LOC01738857706660028', N'textbox', 10, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'6A77A4BE-D225-452D-AE4A-0621A69094B5', N'', N'Any other notifiable symptoms', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', N'Email', N'Email', 1, N'email', 1, N'LOC01738857706660028', N'textbox', 3, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'750E4001-8281-490A-95A3-7D2C57A4375F', N'Designation', N'Designation', 1, N'string', 1, N'LOC01738857706660028', N'textbox', 12, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'79776D76-5BED-42B3-9C5A-47D05346B0A0', N'', N'Respiratory distress (Shortens of breath or breathens difficulties)', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'7D454E8A-5C6E-4ACA-A467-AB7AAC95395A', N'Purpose', N'Purpose', 1, N'string', 2, N'LOC01738857706660028', N'dropdown', 5, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'7EE74742-624B-40D6-BAE0-479626768297', N'', N'Have You visited any of these country in last 30 days? China, Republic of Korea, Iran, Italy, Japan, France, Philipins, Thailand.', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'8665EA12-6B7B-43C1-A68C-A5050888E403', N'', N'Visit any sea food/ animal market as per 1 & 2.', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'948C77C7-3772-430A-86B9-A57FBE773AB0', N'', N'Fever / Hight Temperature', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'9F14579F-B8C4-4E34-8644-CB25B69E8FD9', N'Organization', N'Organization', 1, N'list', 1, N'LOC01738857706660028', N'list', 8, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'9FC395FB-7587-4C7C-9E83-628943A0C68B', N'', N'Have you visited or passed through any country in last 14 days where covid 19 is resorted?', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'B200D9F2-B99B-4984-8B18-B756BBDF7A83', N'Valid From', N'Valid From', 1, N'datetime', 1, N'LOC01738857706660028', N'datetime picker', 13, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'B7BC6A4F-A54A-49F9-838C-1A8147FC437C', N'Visiting DateTime', N'Visiting DateTime', 1, N'datetime', 1, N'LOC01738857706660028', N'datetime picker', 7, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', N'Phone Number', N'Phone Number', 1, N'mobile', 1, N'LOC01738857706660028', N'textbox', 2, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'C6F16AEA-3080-4ADC-81FF-D4A2D7C3DAFB', N'Organization Name', N'Organization Name', 1, N'string', 1, N'LOC01738857706660028', N'textbox', 4, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'D03A6C40-E750-4FCD-B480-9BEBE8F9ED2E', N'Valid To', N'Valid To', 1, N'datetime', 1, N'LOC01738857706660028', N'datetime picker', 14, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'D1D1DFCA-E54E-479F-A9A1-E488D697640E', N'', N'Sore Throat', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'D7495D21-1577-46C0-990E-9F8C4F3462C8', N'', N'Came in close contact of any person suffering from Flu, Corona Virus, other virus, fever and cough as per 1 & 2.', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'D89843BE-8965-4295-B39E-AFFEDF622196', N'Department', N'Department', 1, N'string', 1, N'LOC01738857706660028', N'textbox', 11, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DEA84BA1-5903-45A6-A2A1-EA0F5DFA91F2', N'Remarks', N'Remarks', 1, N'string', 1, N'LOC01738857706660028', N'multiline', 9, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF001', N'Name', N'Name', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 1, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:17.5966667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:17.5966667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF002', N'Phone Number', N'Phone Number', 1, N'mobile', 1, N'ORG01738739262512779', N'textbox', 2, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2000000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF003', N'Email', N'Email', 1, N'email', 1, N'ORG01738739262512779', N'textbox', 3, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2033333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF004', N'Organization Name', N'Organization Name', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 4, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2033333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF005', N'Purpose', N'Purpose', 1, N'string', 2, N'ORG01738739262512779', N'dropdown', 5, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2066667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2066667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF006', N'Whom To meet', N'Whom To meet', 1, N'string', 2, N'ORG01738739262512779', N'textbox', 6, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2066667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2066667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF007', N'Visiting DateTime', N'Visiting DateTime', 1, N'datetime', 1, N'ORG01738739262512779', N'datetime picker', 7, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2066667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2066667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF008', N'', N'Have You visited any of these country in last 30 days? China, Republic of Korea, Iran, Italy, Japan, France, Philipins, Thailand.', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2100000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2100000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF009', N'', N'Have you visited or passed through any country in last 14 days where covid 19 is resorted?', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2100000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2100000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF010', N'', N'Visit any sea food/ animal market as per 1 & 2.', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2133333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2133333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF011', N'', N'Came in close contact of any person suffering from Flu, Corona Virus, other virus, fever and cough as per 1 & 2.', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2133333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2133333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF012', N'', N'Came in contact with the confirmed novel corona virus (covid-19) or other virus patient in the past 14 days?', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2166667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2166667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF013', N'', N'Visit any health facility in home country after travel?', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2166667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2166667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF014', N'', N'Fever / Hight Temperature', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2166667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2166667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF015', N'', N'Cough/ Dry cough', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2200000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2200000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF016', N'', N'Respiratory distress (Shortens of breath or breathens difficulties)', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2200000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2200000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF017', N'', N'Sore Throat', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2200000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2200000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF018', N'', N'Any other notifiable symptoms', 1, N'checkbox', 3, N'ORG01738739262512779', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2233333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2233333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF019', N'Remarks', N'Remarks', 1, N'string', 1, N'ORG01738739262512779', N'multiline', 9, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2233333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2233333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF020', N'Organization', N'Organization', 1, N'list', 1, N'ORG01738739262512779', N'list', 8, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2266667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:12:31.2266667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF021', N'Employee Id', N'Employee Id', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 10, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8166667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8166667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF022', N'Department', N'Department', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 11, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8200000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8200000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF023', N'Designation', N'Designation', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 12, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8200000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8200000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF024', N'Valid From', N'Valid From', 1, N'datetime', 1, N'ORG01738739262512779', N'datetime picker', 13, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8233333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8233333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF025', N'Valid To', N'Valid To', 1, N'datetime', 1, N'ORG01738739262512779', N'datetime picker', 14, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8300000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T14:55:38.8300000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'F7C49CFA-1AD6-416A-9AC2-F68118AFE6B4', N'', N'Came in contact with the confirmed novel corona virus (covid-19) or other virus patient in the past 14 days?', 1, N'checkbox', 3, N'LOC01738857706660028', N'checkbox', 0, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'01FC943F-9AE8-4D4E-92CB-CD5E7D2B5DFF', N'', N'CFD7EBBB-929D-4B9D-A355-07571FA1653D', N'C6F16AEA-3080-4ADC-81FF-D4A2D7C3DAFB', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'045F10DD-0F4A-460D-8DC3-44FA49F26F03', N'', N'EC06F76D-0544-41AA-BD65-F4CC9F0A84FE', N'2233E952-16CC-497C-BF17-CEA17419673A', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'08CE5573-65A5-45A1-8AA0-010383141CEA', N'', N'AACA1412-B333-405D-9963-3376F517C177', N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'1B4B533E-5D8F-47D8-9F99-E06ED9AC3F9A', N'', N'E7724FE9-471A-4E95-9EA7-37652653B2E4', N'8665EA12-6B7B-43C1-A68C-A5050888E403', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'201D9C15-A82C-498D-A2A3-A7623F7909F4', N'', N'562A488E-B74D-45FD-907A-060E93706629', N'F7C49CFA-1AD6-416A-9AC2-F68118AFE6B4', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'3C065E26-E914-4656-9086-B7B9B398EFA5', NULL, N'79AA480C-1805-4D70-9559-3D49057DA82C', N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', NULL, 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'44FCD4A3-88AE-4FAD-AF58-17F7FC70C657', N'', N'80EEE650-8EFF-4575-85C1-882C26450989', N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'476CE20B-CF57-4E43-8048-432198A01CBA', N'', N'B99918B8-8DBF-44D1-B421-D7B2C8C38DF7', N'9F14579F-B8C4-4E34-8644-CB25B69E8FD9', N'', 1, N'BF3DBA81-CDA1-4B5A-9E81-82B32DD5D753', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'4AE9C123-FF04-4D68-A355-D1611C402B4C', N'', N'8DDE8281-FA1D-4DFC-8F07-0DC38EF15CAD', N'6A77A4BE-D225-452D-AE4A-0621A69094B5', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'5171BFAC-74C1-4288-A75F-1FB63BF2215E', NULL, N'0A98C5E9-E9B8-4F3B-B55E-5B657E1956E0', N'C6F16AEA-3080-4ADC-81FF-D4A2D7C3DAFB', NULL, 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'6388F6F7-C539-4F5F-910C-BB037F9DBC91', N'', N'902F6E91-E9B5-446E-81CC-13368BF15C52', N'7EE74742-624B-40D6-BAE0-479626768297', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'66335E8D-0D7F-48C1-80C4-E0DC1B7EDA11', NULL, N'9DCD846D-500A-45D4-80E7-64F790B3F32F', N'7D454E8A-5C6E-4ACA-A467-AB7AAC95395A', NULL, 1, N'6467BD77-EE1E-4E88-9FB7-F13B9DE2AFA3', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'6B9ADD3D-ABDC-43A7-AFC2-D67DD3EC761F', N'', N'3B3580AD-486F-440B-A41E-DFCC0B27CF09', N'D89843BE-8965-4295-B39E-AFFEDF622196', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'6CA6B7EC-0F1E-49CA-9C0E-9DF1C92FE795', N'', N'27969C9F-F6CC-4BCB-977E-20796614663A', N'11832633-98CB-4912-AE55-8ABE2F53EE50', N'', 1, N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'700D7179-D9C8-469F-946D-C67D6B35A1EB', NULL, N'A038188F-A6B9-4535-9E9C-77D007CFB9BB', N'B7BC6A4F-A54A-49F9-838C-1A8147FC437C', NULL, 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'7D18897E-C0B5-41D1-BAC5-E03E62F3E895', N'', N'1234B4AD-DA5E-4478-BFFD-7834471F1E9B', N'D03A6C40-E750-4FCD-B480-9BEBE8F9ED2E', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'8F1A02DA-8A5B-45A2-B023-BF265D1C0C9C', N'', N'4750C6E1-1B3B-4294-87A0-526D615FDF45', N'9FC395FB-7587-4C7C-9E83-628943A0C68B', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'990154AC-CF78-4BBE-8469-178C5CF32B15', N'', N'9E911EA1-7D25-4B91-BCC7-31968B3D657E', N'DEA84BA1-5903-45A6-A2A1-EA0F5DFA91F2', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'9DBE505B-CDE6-4B8E-8ABB-33573894DEB5', NULL, N'CF27B9BF-CC5B-4710-B43B-1348E4931F2E', N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', NULL, 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'ABD689C9-32F4-4933-A548-C6F4D8DFD31C', N'', N'A5580E32-4129-4193-85A8-7E988B5D4C27', N'23BAC2C0-4009-49D9-956B-DF294538C2AF', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'AEF89C92-0663-4D91-A8D3-E6405B29124A', N'', N'97139253-3EFA-4551-AFB2-5B037056FABC', N'5B2874EE-6457-4414-A8AC-845164CBEAAC', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'B2EB0855-DD7D-4F1B-96FC-C295CD8D0F0E', NULL, N'760FC9E1-83A3-418E-BAF8-B33573E93E84', N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', NULL, 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'B96042C4-FDF6-4250-BFB6-5AEB1A3761F3', N'', N'AF31C650-30E5-448A-86E5-8482815D7C9B', N'79776D76-5BED-42B3-9C5A-47D05346B0A0', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'B9E07EAB-0003-4510-84DC-5C283B5E46E3', N'', N'712D6521-82FB-4831-99E7-ED524EA16E00', N'D1D1DFCA-E54E-479F-A9A1-E488D697640E', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'BBEE9574-4A9C-4F8F-8A40-4C9AF6C556F5', NULL, N'DC7F29C2-D07E-484E-9893-DEF033378BC1', N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', NULL, 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'BC3F1923-622C-4AE8-8515-BAA53D15EBC2', N'', N'BA012C4F-DA81-4E8C-A02F-28AFC8B4D276', N'B200D9F2-B99B-4984-8B18-B756BBDF7A83', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'C3DE521C-F15D-42E7-9E73-9BB6D6A4FB07', N'', N'9CD09A1E-A342-47FD-A428-0B1AB1D090CC', N'7D454E8A-5C6E-4ACA-A467-AB7AAC95395A', N'', 1, N'6467BD77-EE1E-4E88-9FB7-F13B9DE2AFA3', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'D9BDD427-F119-4825-8A56-6A006C52C5D7', N'', N'4DBD9D83-1029-4CE2-953B-11FA51D0FAAE', N'750E4001-8281-490A-95A3-7D2C57A4375F', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DF8E7399-4097-4054-9590-FE35DCE9396E', N'', N'D7874847-2784-4D1E-8F0E-8B950F5FFED9', N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO001', N'', N'AF001', N'DF001', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:33:12.3300000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:33:12.3300000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO002', N'', N'AF002', N'DF002', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:33:12.3300000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:33:12.3300000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO003', N'', N'AF003', N'DF003', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:33:12.3333333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:33:12.3333333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO004', N'', N'AF004', N'DF004', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:33:12.3333333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:33:12.3333333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO005', N'', N'AF005', N'DF005', N'', 1, N'ST001', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:34:09.0933333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:34:09.0933333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO006', N'', N'AF006', N'DF006', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:34:52.2500000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:34:52.2500000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO007', N'', N'AF007', N'DF007', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:34:52.2500000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:34:52.2500000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO008', N'', N'AF008', N'DF008', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:36:03.6666667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:36:03.6666667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO009', N'', N'AF009', N'DF009', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:36:03.6700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:36:03.6700000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO010', N'', N'AF010', N'DF010', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1666667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1666667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO011', N'', N'AF011', N'DF011', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1666667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1666667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO012', N'', N'AF012', N'DF012', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1700000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO013', N'', N'AF013', N'DF013', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1700000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO014', N'', N'AF014', N'DF014', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1733333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1733333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO015', N'', N'AF015', N'DF015', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1733333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1733333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO016', N'', N'AF016', N'DF016', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1800000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1800000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO017', N'', N'AF017', N'DF017', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1800000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1800000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO018', N'', N'AF018', N'DF018', N'', 1, N'ST002', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:06.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO019', N'', N'AF019', N'DF019', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:29.2166667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:38:29.2166667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO020', N'', N'AF020', N'DF020', N'', 1, N'ST003', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:39:05.8400000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:39:05.8400000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO021', N'', N'AF021', N'DF021', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3033333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO022', N'', N'AF022', N'DF022', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3066667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3066667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO023', N'', N'AF023', N'DF023', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3100000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3100000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO024', N'', N'AF024', N'DF024', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3100000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3100000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO025', N'', N'AF025', N'DF025', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3133333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-11T15:02:42.3133333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO026', N'', N'AF026', N'DF001', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:58:48.7366667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:58:48.7366667' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO027', N'', N'AF027', N'DF002', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:58:48.7433333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:58:48.7433333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'DFO028', N'', N'AF028', N'DF003', N'', 0, N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:58:48.7500000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T12:58:48.7500000' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'ED087A4E-7A08-4C90-8D0C-7316164B4C8C', N'', N'141C7799-98CE-4C2E-9801-1660F32E9343', N'948C77C7-3772-430A-86B9-A57FBE773AB0', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'ED20740B-8175-4E51-AE99-66A5DD257AF8', NULL, N'EAD5CB0B-B04E-49F4-9522-763EB42ADE09', N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', NULL, 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'EE0DCAD7-0EC0-49DD-B462-7636A2EBC518', N'', N'972BA0A6-270B-445F-9A28-0324AC18AB5D', N'B7BC6A4F-A54A-49F9-838C-1A8147FC437C', N'', 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'F1CF3D69-AAF5-46B1-850C-A407B0528B98', N'', N'5157FDB6-B5EF-41A4-A38C-9CD03CF980AB', N'D7495D21-1577-46C0-990E-9F8C4F3462C8', N'', 1, N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T14:18:19.7033333' AS DateTime2), 0)
GO
INSERT [Visitor].[DynamicFieldOption] ([Id], [Name], [AssignFieldLocationId], [DynamicFieldId], [ImageURL], [IsSourceConnected], [SourceTypeId], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'FBEAB201-B625-4B65-888F-0A897ADDD28C', NULL, N'A5732492-8D0E-4032-999A-2D4B2AD6CD61', N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', NULL, 0, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), 0)
GO
INSERT [Visitor].[EmployeeIdCard] ([Id], [EmployeeId], [Name], [EmailId], [MobileNo], [ValidFrom], [ValidTo], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'F68CD05E-11D5-44CD-A1BC-2ACEA360DA43_1', N'12345', N'Deepak', N'deepak@keabis.com', N'9886147699', CAST(N'2022-07-13T11:41:00.0000000' AS DateTime2), CAST(N'2022-07-14T11:41:00.0000000' AS DateTime2), N'Production', N'iOS', N'', N'LOC01738857706660028', N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), 0)
GO
INSERT [Visitor].[LocationDetails] ([Id], [Name], [Title], [LogoUrl], [BackgroundUrl], [IsOTPRequired], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [isDocumentUrl], [isPhotoUrl]) VALUES (N'A8AAA6F6-814D-41AD-9387-35409323C237', N'KEABIS BLR', N'Welcome to Keabis', N'assets/location/keabislogo.png', N'assets/location/keabisbg.png', 0, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 1, 1)
GO
INSERT [Visitor].[LocationDetails] ([Id], [Name], [Title], [LogoUrl], [BackgroundUrl], [IsOTPRequired], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [isDocumentUrl], [isPhotoUrl]) VALUES (N'LD001', N'Data from KEABIS TECH PVT LTD organization', N'Welcome to Keabis', N'assets/location/keabislogo.png', N'assets/location/keabisbg.png', 1, N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T18:08:53.1000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-06T18:08:53.1000000' AS DateTime2), 0, 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'1', N'Name', N'Name', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 1, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8566667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8566667' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'10', N'Employee Id', N'Employee Id', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 10, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:58:53.6400000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:58:53.6400000' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'11', N'Department', N'Department', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 11, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T14:00:34.0700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T14:00:34.0700000' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'12', N'Designation', N'Designation', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 12, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T14:00:34.0733333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T14:00:34.0733333' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'13', N'Valid From', N'Valid From', 1, N'datetime', 1, N'ORG01738739262512779', N'datetime picker', 13, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T14:00:34.0800000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T14:00:34.0800000' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'14', N'Valid To', N'Valid To', 1, N'datetime', 1, N'ORG01738739262512779', N'datetime picker', 14, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T14:00:34.0800000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T14:00:34.0800000' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'2', N'Phone Number', N'Phone Number', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 2, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8600000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8600000' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'3', N'Email', N'Email', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 3, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8633333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8633333' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'4', N'Organization Name', N'Organization Name', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 4, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8700000' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'5', N'Purpose', N'Purpose', 1, N'string', 1, N'ORG01738739262512779', N'dropdown', 5, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8733333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8733333' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'6', N'Whom To meet', N'Whom To meet', 1, N'string', 1, N'ORG01738739262512779', N'textbox', 6, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8766667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8766667' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'7', N'Visiting DateTime', N'Visiting DateTime', 1, N'datetime', 1, N'ORG01738739262512779', N'datetime picker', 7, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8800000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8800000' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[MasteField] ([Id], [Name], [DisplayText], [IsRequired], [DataType], [AccessId], [TenantId], [Type], [DisplayId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'8', N'Organization', N'Organization', 1, N'list', 1, N'ORG01738739262512779', N'list', 8, N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8866667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-08T13:57:42.8866667' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[SiteVisitor] ([Id], [Name], [PhoneNumber], [Email], [Organization], [UserId], [EmployeeName], [PurposeId], [PhotoImageUrl], [DocumentImageUrl], [SignatureImageUrl], [VisitingDateTime], [CheckInDateTime], [CheckOutDateTime], [IsCheckedOut], [StatusId], [StatusMessage], [Other], [IsInvited], [IsApproved], [ApprovedId], [ApprovedOn], [ClientId], [IsNotAccectable], [VisitorCode], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'Md Imran Ali', N'9708216254', N'imran@keabis.com', N'Keabis Tech', NULL, N'Deepak Rajendran', N'Meeting', N'00.jpg', N'00.jpg', NULL, CAST(N'2022-07-12T16:50:10.0000000' AS DateTime2), CAST(N'2022-07-12T16:50:10.0000000' AS DateTime2), CAST(N'2022-07-12T16:50:10.0000000' AS DateTime2), 0, 1, NULL, NULL, 0, 0, N'00.jpg', NULL, N'Keabis Bangalore', 0, NULL, N'LOC01738857706660028', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0)
GO
INSERT [Visitor].[SiteVisitor] ([Id], [Name], [PhoneNumber], [Email], [Organization], [UserId], [EmployeeName], [PurposeId], [PhotoImageUrl], [DocumentImageUrl], [SignatureImageUrl], [VisitingDateTime], [CheckInDateTime], [CheckOutDateTime], [IsCheckedOut], [StatusId], [StatusMessage], [Other], [IsInvited], [IsApproved], [ApprovedId], [ApprovedOn], [ClientId], [IsNotAccectable], [VisitorCode], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'F04B9D10-1C21-4DFF-A467-04FFA344F96C', N'Md', N'9708216254', N'imran@keabis.com', N'Keabis Tech', NULL, NULL, N'Meeting', N'00.jpg', N'00.jpg', NULL, CAST(N'2022-07-13T20:26:09.0000000' AS DateTime2), CAST(N'2022-07-13T20:26:09.0000000' AS DateTime2), CAST(N'2022-07-13T20:26:09.0000000' AS DateTime2), 0, 6, NULL, NULL, 1, 0, NULL, NULL, NULL, 0, NULL, N'LOC01738857706660028', N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), 0)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'06CB667A-4589-4B72-BE88-F1125D65353B', N'Interview', N'6467BD77-EE1E-4E88-9FB7-F13B9DE2AFA3', N'', 0, N'', N'', N'', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'2804A620-9BDA-4E79-9362-FAC804B09B80', N'Madhu', N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', NULL, 0, NULL, NULL, NULL, NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'3D61E6A9-7CE1-4DDA-BABF-F491B1BD3F5B', N'Nitheesh', N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', NULL, 0, NULL, NULL, NULL, NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'4A4706A6-527A-41DA-9A77-90B9D6F80C48', N'Dharshan', N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', NULL, 0, NULL, NULL, NULL, NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'5E072739-DF97-45EE-B6AA-327FBEABCA14', N'Meeting', N'6467BD77-EE1E-4E88-9FB7-F13B9DE2AFA3', N'', 0, N'', N'', N'', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'No', N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'', 0, N'', N'', N'', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'87580422-0677-4965-B3DE-3B65CFA06A9E', N'Neeraj', N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', NULL, 0, NULL, NULL, NULL, NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'98B0F1E8-6CF8-4930-9A1F-DDBBB4CD35D8', N'Ravi', N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', NULL, 0, NULL, NULL, NULL, NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'CBCBCBA6-447E-443D-BDB4-49BF937CCF85', N'Keabis Bangalore', N'BF3DBA81-CDA1-4B5A-9E81-82B32DD5D753', N'', 0, N'', N'', N'', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 1, N'', N'', N'')
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'CBD0959B-FB81-402B-9359-43B766A7321B', N'Yes', N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'', 1, N'', N'', N'', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'CDCC865F-E61B-4096-B6A8-9C7AFEA33430', N'Krishna', N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', NULL, 0, NULL, NULL, NULL, NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'D9BCD559-61FE-4121-82AA-3E14B009F554', N'Syam', N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', NULL, 0, NULL, NULL, NULL, NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'F34EA79A-22D0-43A9-815F-4F041CD01921', N'Deepak Rajendran', N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', NULL, 0, NULL, NULL, NULL, NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'F43EC46C-8AEE-4321-8251-CF17601001C8', N'Thangaraj', N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', NULL, 0, NULL, NULL, NULL, NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'SD001', N'Meeting', N'ST001', N'', 0, N'', N'', N'', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:00:32.4300000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:00:32.4300000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'SD002', N'Interview', N'ST001', N'', 0, N'', N'', N'', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:00:32.7700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:00:32.7700000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'SD003', N'Yes', N'ST002', N'', 1, N'', N'', N'', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:01:17.4466667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:01:17.4466667' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'SD004', N'No', N'ST002', N'', 0, N'', N'', N'', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:01:17.4500000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:01:17.4500000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'SD005', N'Keabis HO', N'ST003', N'', 0, N'', N'', N'', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:44:23.9400000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:44:23.9400000' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceData] ([Id], [Name], [SourceTypeId], [Description], [IsTriggerNotification], [ImageUrl], [ColorCode], [Data1], [Data2], [Data3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SeqNo], [Data4], [Data5], [Data6]) VALUES (N'SD006', N'Kleentech', N'ST003', N'', 0, N'', N'', N'', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:44:23.9433333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:44:23.9433333' AS DateTime2), 0, 0, NULL, NULL, NULL)
GO
INSERT [Visitor].[SourceType] ([Id], [Name], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [DisplayId]) VALUES (N'6467BD77-EE1E-4E88-9FB7-F13B9DE2AFA3', N'Visitor Purpose', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 5)
GO
INSERT [Visitor].[SourceType] ([Id], [Name], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [DisplayId]) VALUES (N'BF3DBA81-CDA1-4B5A-9E81-82B32DD5D753', N'Organization', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 8)
GO
INSERT [Visitor].[SourceType] ([Id], [Name], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [DisplayId]) VALUES (N'E9D9B545-37A7-4AAA-A164-23C2562DAFD8', N'Yes/No Option', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[SourceType] ([Id], [Name], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [DisplayId]) VALUES (N'FBC7052B-4CDD-47A2-A95C-AD198E3AB154', N'Employee List', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:23:16.3700000' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[SourceType] ([Id], [Name], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [DisplayId]) VALUES (N'ST001', N'Visitor Purpose', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:57:29.5500000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:57:29.5500000' AS DateTime2), 0, 5)
GO
INSERT [Visitor].[SourceType] ([Id], [Name], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [DisplayId]) VALUES (N'ST002', N'Yes/No Option', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:57:56.2300000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:57:56.2300000' AS DateTime2), 0, 0)
GO
INSERT [Visitor].[SourceType] ([Id], [Name], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [DisplayId]) VALUES (N'ST003', N'Organization', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:40:45.6866667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T01:40:45.6866667' AS DateTime2), 0, 8)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'0B4051BC-5BF3-42AE-861D-C9DEE869A5BD', N'Keabis Tech', N'0A98C5E9-E9B8-4F3B-B55E-5B657E1956E0', N'C6F16AEA-3080-4ADC-81FF-D4A2D7C3DAFB', N'LOC01738857706660028', N'5171BFAC-74C1-4288-A75F-1FB63BF2215E', N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), 0, N'F04B9D10-1C21-4DFF-A467-04FFA344F96C', N'5171BFAC-74C1-4288-A75F-1FB63BF2215E', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'10CD5863-F345-4CC5-99E0-D3BCBC1AA54B', N'13-Jul-2022 11:41 AM', N'BA012C4F-DA81-4E8C-A02F-28AFC8B4D276', N'B200D9F2-B99B-4984-8B18-B756BBDF7A83', N'LOC01738857706660028', N'BC3F1923-622C-4AE8-8515-BAA53D15EBC2', N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), 0, N'F68CD05E-11D5-44CD-A1BC-2ACEA360DA43_1', N'BC3F1923-622C-4AE8-8515-BAA53D15EBC2', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'200ED4C7-45B9-41F8-A178-880DCF14A4B9', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'A5580E32-4129-4193-85A8-7E988B5D4C27', N'23BAC2C0-4009-49D9-956B-DF294538C2AF', N'LOC01738857706660028', N'ABD689C9-32F4-4933-A548-C6F4D8DFD31C', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'ABD689C9-32F4-4933-A548-C6F4D8DFD31C', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'245DAAEB-DD9F-480C-86B7-D676CCE09543', N'imran@keabis.com', N'80EEE650-8EFF-4575-85C1-882C26450989', N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', N'LOC01738857706660028', N'44FCD4A3-88AE-4FAD-AF58-17F7FC70C657', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'44FCD4A3-88AE-4FAD-AF58-17F7FC70C657', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'2C7A63E7-A378-4EEB-90CB-E8ADBFBDE7B8', N'12-Jul-2022 04:49 PM', N'972BA0A6-270B-445F-9A28-0324AC18AB5D', N'B7BC6A4F-A54A-49F9-838C-1A8147FC437C', N'LOC01738857706660028', N'EE0DCAD7-0EC0-49DD-B462-7636A2EBC518', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'EE0DCAD7-0EC0-49DD-B462-7636A2EBC518', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'2D004919-6EB3-496E-8871-D8C678B6A5D5', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'5157FDB6-B5EF-41A4-A38C-9CD03CF980AB', N'D7495D21-1577-46C0-990E-9F8C4F3462C8', N'LOC01738857706660028', N'F1CF3D69-AAF5-46B1-850C-A407B0528B98', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'F1CF3D69-AAF5-46B1-850C-A407B0528B98', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'34A7B2AF-ED42-46AC-A4CF-C295EEBEA73C', N'CBCBCBA6-447E-443D-BDB4-49BF937CCF85', N'B99918B8-8DBF-44D1-B421-D7B2C8C38DF7', N'9F14579F-B8C4-4E34-8644-CB25B69E8FD9', N'LOC01738857706660028', N'476CE20B-CF57-4E43-8048-432198A01CBA', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'476CE20B-CF57-4E43-8048-432198A01CBA', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'3877DD54-FFD3-4734-AB30-5BD057B91C3B', N'Production', N'3B3580AD-486F-440B-A41E-DFCC0B27CF09', N'D89843BE-8965-4295-B39E-AFFEDF622196', N'LOC01738857706660028', N'6B9ADD3D-ABDC-43A7-AFC2-D67DD3EC761F', N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), 0, N'F68CD05E-11D5-44CD-A1BC-2ACEA360DA43_1', N'6B9ADD3D-ABDC-43A7-AFC2-D67DD3EC761F', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'4DE30568-97FB-4D03-9D64-CA82DC9E55B1', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'902F6E91-E9B5-446E-81CC-13368BF15C52', N'7EE74742-624B-40D6-BAE0-479626768297', N'LOC01738857706660028', N'6388F6F7-C539-4F5F-910C-BB037F9DBC91', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'6388F6F7-C539-4F5F-910C-BB037F9DBC91', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'513B8271-76AF-49E0-85E3-E90217CC8962', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'141C7799-98CE-4C2E-9801-1660F32E9343', N'948C77C7-3772-430A-86B9-A57FBE773AB0', N'LOC01738857706660028', N'ED087A4E-7A08-4C90-8D0C-7316164B4C8C', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'ED087A4E-7A08-4C90-8D0C-7316164B4C8C', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'5B525231-7AE0-4140-85BB-A1E15983A9E1', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'562A488E-B74D-45FD-907A-060E93706629', N'F7C49CFA-1AD6-416A-9AC2-F68118AFE6B4', N'LOC01738857706660028', N'201D9C15-A82C-498D-A2A3-A7623F7909F4', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'201D9C15-A82C-498D-A2A3-A7623F7909F4', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'5FA1A0A4-6860-43D2-A927-C13801379941', N'13-Jul-2022', N'A038188F-A6B9-4535-9E9C-77D007CFB9BB', N'B7BC6A4F-A54A-49F9-838C-1A8147FC437C', N'LOC01738857706660028', N'700D7179-D9C8-469F-946D-C67D6B35A1EB', N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), 0, N'F04B9D10-1C21-4DFF-A467-04FFA344F96C', N'700D7179-D9C8-469F-946D-C67D6B35A1EB', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'617277E9-0EF8-4D6D-8CF4-C4867D006999', N'F34EA79A-22D0-43A9-815F-4F041CD01921', N'27969C9F-F6CC-4BCB-977E-20796614663A', N'11832633-98CB-4912-AE55-8ABE2F53EE50', N'LOC01738857706660028', N'6CA6B7EC-0F1E-49CA-9C0E-9DF1C92FE795', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'6CA6B7EC-0F1E-49CA-9C0E-9DF1C92FE795', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'67FDD983-5961-4960-B3AB-8CECD18E6C6A', N'5E072739-DF97-45EE-B6AA-327FBEABCA14', N'9DCD846D-500A-45D4-80E7-64F790B3F32F', N'7D454E8A-5C6E-4ACA-A467-AB7AAC95395A', N'LOC01738857706660028', N'66335E8D-0D7F-48C1-80C4-E0DC1B7EDA11', N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), 0, N'F04B9D10-1C21-4DFF-A467-04FFA344F96C', N'66335E8D-0D7F-48C1-80C4-E0DC1B7EDA11', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'6A2F4B3A-67E4-42C4-8B31-59C15985F3DF', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'712D6521-82FB-4831-99E7-ED524EA16E00', N'D1D1DFCA-E54E-479F-A9A1-E488D697640E', N'LOC01738857706660028', N'B9E07EAB-0003-4510-84DC-5C283B5E46E3', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'B9E07EAB-0003-4510-84DC-5C283B5E46E3', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'6B792420-1750-4B9B-8EC8-3EA16FDA783B', N'Keabis Tech', N'CFD7EBBB-929D-4B9D-A355-07571FA1653D', N'C6F16AEA-3080-4ADC-81FF-D4A2D7C3DAFB', N'LOC01738857706660028', N'01FC943F-9AE8-4D4E-92CB-CD5E7D2B5DFF', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'01FC943F-9AE8-4D4E-92CB-CD5E7D2B5DFF', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'74B6905D-0955-4DA2-805A-9068087C9872', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'E7724FE9-471A-4E95-9EA7-37652653B2E4', N'8665EA12-6B7B-43C1-A68C-A5050888E403', N'LOC01738857706660028', N'1B4B533E-5D8F-47D8-9F99-E06ED9AC3F9A', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'1B4B533E-5D8F-47D8-9F99-E06ED9AC3F9A', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'89C28BE3-2D3C-40D2-8D76-8E66C50DECAE', N'iOS', N'4DBD9D83-1029-4CE2-953B-11FA51D0FAAE', N'750E4001-8281-490A-95A3-7D2C57A4375F', N'LOC01738857706660028', N'D9BDD427-F119-4825-8A56-6A006C52C5D7', N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), 0, N'F68CD05E-11D5-44CD-A1BC-2ACEA360DA43_1', N'D9BDD427-F119-4825-8A56-6A006C52C5D7', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'8DDEB704-F819-4E54-A522-FC82190F7CE8', N'12345', N'97139253-3EFA-4551-AFB2-5B037056FABC', N'5B2874EE-6457-4414-A8AC-845164CBEAAC', N'LOC01738857706660028', N'AEF89C92-0663-4D91-A8D3-E6405B29124A', N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), 0, N'F68CD05E-11D5-44CD-A1BC-2ACEA360DA43_1', N'AEF89C92-0663-4D91-A8D3-E6405B29124A', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'8EE70B8F-CC81-4F30-B200-1A5965A1177B', N'9708216254', N'760FC9E1-83A3-418E-BAF8-B33573E93E84', N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', N'LOC01738857706660028', N'B2EB0855-DD7D-4F1B-96FC-C295CD8D0F0E', N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), 0, N'F04B9D10-1C21-4DFF-A467-04FFA344F96C', N'B2EB0855-DD7D-4F1B-96FC-C295CD8D0F0E', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'A89431D5-D677-4A1E-83DE-9C597BB42B3E', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'EC06F76D-0544-41AA-BD65-F4CC9F0A84FE', N'2233E952-16CC-497C-BF17-CEA17419673A', N'LOC01738857706660028', N'045F10DD-0F4A-460D-8DC3-44FA49F26F03', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'045F10DD-0F4A-460D-8DC3-44FA49F26F03', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'C66D715F-A015-436D-9E6F-CD022D1CFB6C', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'AF31C650-30E5-448A-86E5-8482815D7C9B', N'79776D76-5BED-42B3-9C5A-47D05346B0A0', N'LOC01738857706660028', N'B96042C4-FDF6-4250-BFB6-5AEB1A3761F3', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'B96042C4-FDF6-4250-BFB6-5AEB1A3761F3', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'CC7BE45D-8F43-4D1A-8FB8-01AF39E62371', N'Md', N'A5732492-8D0E-4032-999A-2D4B2AD6CD61', N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', N'LOC01738857706660028', N'FBEAB201-B625-4B65-888F-0A897ADDD28C', N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), 0, N'F04B9D10-1C21-4DFF-A467-04FFA344F96C', N'FBEAB201-B625-4B65-888F-0A897ADDD28C', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'CE3F3D8C-4CA2-49E6-9288-20725E6EE368', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'4750C6E1-1B3B-4294-87A0-526D615FDF45', N'9FC395FB-7587-4C7C-9E83-628943A0C68B', N'LOC01738857706660028', N'8F1A02DA-8A5B-45A2-B023-BF265D1C0C9C', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'8F1A02DA-8A5B-45A2-B023-BF265D1C0C9C', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'D4FE9901-5390-4F1E-98CA-A2ECF60A01A5', N'Md Imran Ali', N'D7874847-2784-4D1E-8F0E-8B950F5FFED9', N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', N'LOC01738857706660028', N'DF8E7399-4097-4054-9590-FE35DCE9396E', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'DF8E7399-4097-4054-9590-FE35DCE9396E', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'E07D9CB5-2F46-41DC-8B31-EB87081E6A83', N'Deepak', N'EAD5CB0B-B04E-49F4-9522-763EB42ADE09', N'491142AF-0AB9-4A58-A72A-30867AAC1D0A', N'LOC01738857706660028', N'ED20740B-8175-4E51-AE99-66A5DD257AF8', N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), 0, N'F68CD05E-11D5-44CD-A1BC-2ACEA360DA43_1', N'ED20740B-8175-4E51-AE99-66A5DD257AF8', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'E190D6BA-0D4B-4FD3-900E-018C80B2F28B', N'9708216254', N'AACA1412-B333-405D-9963-3376F517C177', N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', N'LOC01738857706660028', N'08CE5573-65A5-45A1-8AA0-010383141CEA', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'08CE5573-65A5-45A1-8AA0-010383141CEA', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'F1997F1E-85F7-46C9-8BA1-F957BFB348D7', N'Sfsdf', N'9E911EA1-7D25-4B91-BCC7-31968B3D657E', N'DEA84BA1-5903-45A6-A2A1-EA0F5DFA91F2', N'LOC01738857706660028', N'990154AC-CF78-4BBE-8469-178C5CF32B15', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'990154AC-CF78-4BBE-8469-178C5CF32B15', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'F29671BD-D450-4F44-A313-4CEFCB8AA648', N'imran@keabis.com', N'DC7F29C2-D07E-484E-9893-DEF033378BC1', N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', N'LOC01738857706660028', N'BBEE9574-4A9C-4F8F-8A40-4C9AF6C556F5', N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T20:26:09.6666667' AS DateTime2), 0, N'F04B9D10-1C21-4DFF-A467-04FFA344F96C', N'BBEE9574-4A9C-4F8F-8A40-4C9AF6C556F5', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'F77AA692-7E0A-41B7-9957-4CCEFE7CD843', N'deepak@keabis.com', N'CF27B9BF-CC5B-4710-B43B-1348E4931F2E', N'6FD4BC26-FC19-4C4C-921A-7CFB8C32CD31', N'LOC01738857706660028', N'9DBE505B-CDE6-4B8E-8ABB-33573894DEB5', N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), 0, N'F68CD05E-11D5-44CD-A1BC-2ACEA360DA43_1', N'9DBE505B-CDE6-4B8E-8ABB-33573894DEB5', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'F9D67B69-DA99-4828-9070-23411A6227F6', N'14-Jul-2022 11:41 AM', N'1234B4AD-DA5E-4478-BFFD-7834471F1E9B', N'D03A6C40-E750-4FCD-B480-9BEBE8F9ED2E', N'LOC01738857706660028', N'7D18897E-C0B5-41D1-BAC5-E03E62F3E895', N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), 0, N'F68CD05E-11D5-44CD-A1BC-2ACEA360DA43_1', N'7D18897E-C0B5-41D1-BAC5-E03E62F3E895', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'FCC82A1B-7F51-422F-AF8B-4C239DBDF298', N'6958F478-9D52-4C9A-949A-1E9C5B5DE109', N'8DDE8281-FA1D-4DFC-8F07-0DC38EF15CAD', N'6A77A4BE-D225-452D-AE4A-0621A69094B5', N'LOC01738857706660028', N'4AE9C123-FF04-4D68-A355-D1611C402B4C', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'4AE9C123-FF04-4D68-A355-D1611C402B4C', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'FD4C0EDE-B744-45CE-9CBF-E6DAE439D6DA', N'5E072739-DF97-45EE-B6AA-327FBEABCA14', N'9CD09A1E-A342-47FD-A428-0B1AB1D090CC', N'7D454E8A-5C6E-4ACA-A467-AB7AAC95395A', N'LOC01738857706660028', N'C3DE521C-F15D-42E7-9E73-9BB6D6A4FB07', N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-12T16:50:11.2866667' AS DateTime2), 0, N'3E4CCB5F-8B8C-468C-A17E-F3661B845B90', N'C3DE521C-F15D-42E7-9E73-9BB6D6A4FB07', 0)
GO
INSERT [Visitor].[VisitorDataCollection] ([Id], [FieldValue], [AssignFieldLocationId], [DynamicFieldId], [TenantId], [Description], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [VisitorId], [DynamicFieldOptionId], [IsTriggerNotification]) VALUES (N'FFED2207-C329-4ADC-A851-CA419255C8F6', N'9886147699', N'79AA480C-1805-4D70-9559-3D49057DA82C', N'C25BAFCE-E42C-4F8D-9781-84611585FCE8', N'LOC01738857706660028', N'3C065E26-E914-4656-9086-B7B9B398EFA5', N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), N'USR01738859499395145', CAST(N'2022-07-13T13:48:41.6500000' AS DateTime2), 0, N'F68CD05E-11D5-44CD-A1BC-2ACEA360DA43_1', N'3C065E26-E914-4656-9086-B7B9B398EFA5', 0)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'06033171-8019-4CE9-B0B3-2171275DF30C', 2, N'Visitor Details', N'Please fill the following information', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'11FF4581-AED5-49BD-80C9-1642026AD975', 7, N'Client', N'Select Organization you wish to visit', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'5B045B04-60F5-4E42-8FD0-CF9BD7326B6E', 3, N'Declaration', N'Health & safety is an integral part of our business, in order to prevent the spread of Novel corona virus (Covid 19) or any other virus with in our community and reduce the risk of exposure to our staff, workers and visitors,we are conducting simple screening questionnaires.', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'7B461703-C2D0-492E-8E95-0AB6EC037CDA', 1, N'Employee Details', N'Employee Details', NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:06:57.1833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T13:07:47.9766667' AS DateTime2), 0, 3)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'AD4CD361-9695-4C3D-9328-E77DFA22ED00', 1, N'Visitor Details', N'Visitor Details', NULL, NULL, N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:23:52.6000000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-13T17:25:55.4833333' AS DateTime2), 0, 2)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'BE15728C-71D8-4D40-9DA9-01460AD00FFD', 5, N'Declaration', N'Health & safety is an integral part of our business, in order to prevent the spread of Novel corona virus (Covid 19) or any other virus with in our community and reduce the risk of exposure to our staff, workers and visitors,we are conducting simple screening questionnaires.', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'C4CFE0BB-014E-4614-AD74-CE73AB4E3327', 6, N'Declaration', N'Health & safety is an integral part of our business, in order to prevent the spread of Novel corona virus (Covid 19) or any other virus with in our community and reduce the risk of exposure to our staff, workers and visitors,we are conducting simple screening questionnaires.', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'E0D026DA-EF3B-4CB1-B1A7-28028E4E43E4', 1, N'Visitor Details', N'Please fill the following information', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T19:20:37.0800000' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'F32F6A94-9B85-44FE-B2C3-A01B8C68B373', 4, N'Declaration', N'Health & safety is an integral part of our business, in order to prevent the spread of Novel corona virus (Covid 19) or any other virus with in our community and reduce the risk of exposure to our staff, workers and visitors,we are conducting simple screening questionnaires.', N'', N'', N'LOC01738857706660028', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-12T13:17:35.4833333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'VH001', 1, N'Visitor Details', N'Please fill the following information', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:22:42.9733333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:22:42.9733333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'VH002', 2, N'Visitor Details', N'Please fill the following information', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:22:57.0033333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:22:57.0033333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'VH003', 3, N'Declaration', N'Health & safety is an integral part of our business, in order to prevent the spread of Novel corona virus (Covid 19) or any other virus with in our community and reduce the risk of exposure to our staff, workers and visitors,we are conducting simple screening questionnaires.', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:10.2200000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:10.2200000' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'VH004', 4, N'Declaration', N'Health & safety is an integral part of our business, in order to prevent the spread of Novel corona virus (Covid 19) or any other virus with in our community and reduce the risk of exposure to our staff, workers and visitors,we are conducting simple screening questionnaires.', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:25.9633333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:25.9633333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'VH005', 5, N'Declaration', N'Health & safety is an integral part of our business, in order to prevent the spread of Novel corona virus (Covid 19) or any other virus with in our community and reduce the risk of exposure to our staff, workers and visitors,we are conducting simple screening questionnaires.', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:36.8866667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:36.8866667' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'VH006', 6, N'Declaration', N'Health & safety is an integral part of our business, in order to prevent the spread of Novel corona virus (Covid 19) or any other virus with in our community and reduce the risk of exposure to our staff, workers and visitors,we are conducting simple screening questionnaires.', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:46.4866667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:46.4866667' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'VH007', 7, N'Client', N'Select Organization you wish to visit', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:56.5833333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:23:56.5833333' AS DateTime2), 0, 1)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'VH008', 1, N'Employee Details', N'Please fill the following information', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:22:42.9733333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:22:42.9733333' AS DateTime2), 0, 3)
GO
INSERT [Visitor].[VisitorHeader] ([Id], [PageId], [PageTitle], [Header1], [Header2], [Header3], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted], [SourceId]) VALUES (N'VH009', 1, N'Visitor Details', N'Please fill the following information', N'', N'', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:22:42.9733333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T17:22:42.9733333' AS DateTime2), 0, 2)
GO
INSERT [Visitor].[VisitorMenu] ([Id], [Name], [Title], [MenuUrl], [ColorCode], [TextColor], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'1', N'Check In', N'1', N'assets/location/checkin.png', N'#000000', N'#FFFFFF', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:19:04.5466667' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:19:04.5466667' AS DateTime2), 0)
GO
INSERT [Visitor].[VisitorMenu] ([Id], [Name], [Title], [MenuUrl], [ColorCode], [TextColor], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'2', N'Check Out', N'2', N'assets/location/checkout.png', N'#FFFFFF', N'#000000', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:19:30.1600000' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:19:30.1600000' AS DateTime2), 0)
GO
INSERT [Visitor].[VisitorMenu] ([Id], [Name], [Title], [MenuUrl], [ColorCode], [TextColor], [TenantId], [CreatedById], [CreatedOn], [ModifiedById], [ModifiedOn], [IsDeleted]) VALUES (N'3', N'Employee', N'3', N'assets/location/employee.png', N'#000000', N'#FFFFFF', N'ORG01738739262512779', N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:21:28.7133333' AS DateTime2), N'BUILTIN_USER_SUPER_ADMIN', CAST(N'2022-07-07T00:21:28.7133333' AS DateTime2), 0)
GO
ALTER TABLE [Visitor].[LocationDetails] ADD  DEFAULT (CONVERT([bit],(0))) FOR [isDocumentUrl]
GO
ALTER TABLE [Visitor].[LocationDetails] ADD  DEFAULT (CONVERT([bit],(0))) FOR [isPhotoUrl]
GO
ALTER TABLE [Visitor].[MasteField] ADD  DEFAULT ((0)) FOR [SourceId]
GO
ALTER TABLE [Visitor].[SourceData] ADD  DEFAULT ((0)) FOR [SeqNo]
GO
ALTER TABLE [Visitor].[SourceType] ADD  DEFAULT ((0)) FOR [DisplayId]
GO
ALTER TABLE [Visitor].[VisitorDataCollection] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsTriggerNotification]
GO
ALTER TABLE [Visitor].[VisitorHeader] ADD  DEFAULT ((0)) FOR [SourceId]
GO
ALTER TABLE [dashboard].[DashboardLayouts]  WITH CHECK ADD  CONSTRAINT [FK_DashboardLayouts_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [dashboard].[DashboardLayouts] CHECK CONSTRAINT [FK_DashboardLayouts_Locations_TenantId]
GO
ALTER TABLE [dashboard].[DashboardLayouts]  WITH CHECK ADD  CONSTRAINT [FK_DashboardLayouts_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dashboard].[DashboardLayouts] CHECK CONSTRAINT [FK_DashboardLayouts_Users_CreatedById]
GO
ALTER TABLE [dashboard].[DashboardLayouts]  WITH CHECK ADD  CONSTRAINT [FK_DashboardLayouts_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dashboard].[DashboardLayouts] CHECK CONSTRAINT [FK_DashboardLayouts_Users_ModifiedById]
GO
ALTER TABLE [dashboard].[DashboardLayouts]  WITH CHECK ADD  CONSTRAINT [FK_DashboardLayouts_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dashboard].[DashboardLayouts] CHECK CONSTRAINT [FK_DashboardLayouts_Users_UserId]
GO
ALTER TABLE [dashboard].[WidgetFields]  WITH CHECK ADD  CONSTRAINT [FK_WidgetFields_WidgetMetadata_WidgetMetadataId] FOREIGN KEY([WidgetMetadataId])
REFERENCES [dashboard].[WidgetMetadata] ([Id])
GO
ALTER TABLE [dashboard].[WidgetFields] CHECK CONSTRAINT [FK_WidgetFields_WidgetMetadata_WidgetMetadataId]
GO
ALTER TABLE [dashboard].[WidgetGroups]  WITH CHECK ADD  CONSTRAINT [FK_WidgetGroups_DashboardLayouts_LayoutId] FOREIGN KEY([LayoutId])
REFERENCES [dashboard].[DashboardLayouts] ([Id])
GO
ALTER TABLE [dashboard].[WidgetGroups] CHECK CONSTRAINT [FK_WidgetGroups_DashboardLayouts_LayoutId]
GO
ALTER TABLE [dashboard].[WidgetGroups]  WITH CHECK ADD  CONSTRAINT [FK_WidgetGroups_Locations_LocationId] FOREIGN KEY([LocationId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [dashboard].[WidgetGroups] CHECK CONSTRAINT [FK_WidgetGroups_Locations_LocationId]
GO
ALTER TABLE [dashboard].[WidgetGroups]  WITH CHECK ADD  CONSTRAINT [FK_WidgetGroups_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dashboard].[WidgetGroups] CHECK CONSTRAINT [FK_WidgetGroups_Users_CreatedById]
GO
ALTER TABLE [dashboard].[WidgetGroups]  WITH CHECK ADD  CONSTRAINT [FK_WidgetGroups_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dashboard].[WidgetGroups] CHECK CONSTRAINT [FK_WidgetGroups_Users_ModifiedById]
GO
ALTER TABLE [dashboard].[WidgetMetadata]  WITH CHECK ADD  CONSTRAINT [FK_WidgetMetadata_ReportDataSources_DataSourceId] FOREIGN KEY([DataSourceId])
REFERENCES [dashboard].[ReportDataSources] ([Id])
GO
ALTER TABLE [dashboard].[WidgetMetadata] CHECK CONSTRAINT [FK_WidgetMetadata_ReportDataSources_DataSourceId]
GO
ALTER TABLE [dashboard].[WidgetMetadata]  WITH CHECK ADD  CONSTRAINT [FK_WidgetMetadata_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dashboard].[WidgetMetadata] CHECK CONSTRAINT [FK_WidgetMetadata_Users_CreatedById]
GO
ALTER TABLE [dashboard].[WidgetMetadata]  WITH CHECK ADD  CONSTRAINT [FK_WidgetMetadata_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dashboard].[WidgetMetadata] CHECK CONSTRAINT [FK_WidgetMetadata_Users_ModifiedById]
GO
ALTER TABLE [dashboard].[Widgets]  WITH CHECK ADD  CONSTRAINT [FK_Widgets_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dashboard].[Widgets] CHECK CONSTRAINT [FK_Widgets_Users_CreatedById]
GO
ALTER TABLE [dashboard].[Widgets]  WITH CHECK ADD  CONSTRAINT [FK_Widgets_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dashboard].[Widgets] CHECK CONSTRAINT [FK_Widgets_Users_ModifiedById]
GO
ALTER TABLE [dashboard].[Widgets]  WITH CHECK ADD  CONSTRAINT [FK_Widgets_WidgetGroups_WidgetGroupId] FOREIGN KEY([WidgetGroupId])
REFERENCES [dashboard].[WidgetGroups] ([Id])
GO
ALTER TABLE [dashboard].[Widgets] CHECK CONSTRAINT [FK_Widgets_WidgetGroups_WidgetGroupId]
GO
ALTER TABLE [datafilter].[FilterGroups]  WITH CHECK ADD  CONSTRAINT [FK_FilterGroups_FilterGroups_FilterGroupId] FOREIGN KEY([FilterGroupId])
REFERENCES [datafilter].[FilterGroups] ([Id])
GO
ALTER TABLE [datafilter].[FilterGroups] CHECK CONSTRAINT [FK_FilterGroups_FilterGroups_FilterGroupId]
GO
ALTER TABLE [datafilter].[FilterItems]  WITH CHECK ADD  CONSTRAINT [FK_FilterItems_FilterGroups_FilterGroupId] FOREIGN KEY([FilterGroupId])
REFERENCES [datafilter].[FilterGroups] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [datafilter].[FilterItems] CHECK CONSTRAINT [FK_FilterItems_FilterGroups_FilterGroupId]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_Locations_Locations_ParentLocationId] FOREIGN KEY([ParentLocationId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_Locations_Locations_ParentLocationId]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_Locations_LocationTypes_LocationTypeId] FOREIGN KEY([LocationTypeId])
REFERENCES [dbo].[LocationTypes] ([Id])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_Locations_LocationTypes_LocationTypeId]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_Locations_Organizations_OrganizationId] FOREIGN KEY([OrganizationId])
REFERENCES [dbo].[Organizations] ([Id])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_Locations_Organizations_OrganizationId]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_Locations_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_Locations_Users_CreatedById]
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD  CONSTRAINT [FK_Locations_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Locations] CHECK CONSTRAINT [FK_Locations_Users_ModifiedById]
GO
ALTER TABLE [dbo].[LocationTypes]  WITH CHECK ADD  CONSTRAINT [FK_LocationTypes_Organizations_OrganizationId] FOREIGN KEY([OrganizationId])
REFERENCES [dbo].[Organizations] ([Id])
GO
ALTER TABLE [dbo].[LocationTypes] CHECK CONSTRAINT [FK_LocationTypes_Organizations_OrganizationId]
GO
ALTER TABLE [dbo].[LocationTypes]  WITH CHECK ADD  CONSTRAINT [FK_LocationTypes_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[LocationTypes] CHECK CONSTRAINT [FK_LocationTypes_Users_CreatedById]
GO
ALTER TABLE [dbo].[LocationTypes]  WITH CHECK ADD  CONSTRAINT [FK_LocationTypes_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[LocationTypes] CHECK CONSTRAINT [FK_LocationTypes_Users_ModifiedById]
GO
ALTER TABLE [dbo].[Organizations]  WITH CHECK ADD  CONSTRAINT [FK_Organizations_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Organizations] CHECK CONSTRAINT [FK_Organizations_Users_CreatedById]
GO
ALTER TABLE [dbo].[Organizations]  WITH CHECK ADD  CONSTRAINT [FK_Organizations_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Organizations] CHECK CONSTRAINT [FK_Organizations_Users_ModifiedById]
GO
ALTER TABLE [dbo].[Roles]  WITH CHECK ADD  CONSTRAINT [FK_Roles_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [dbo].[Roles] CHECK CONSTRAINT [FK_Roles_Locations_TenantId]
GO
ALTER TABLE [dbo].[Tokens]  WITH CHECK ADD  CONSTRAINT [FK_Tokens_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Tokens] CHECK CONSTRAINT [FK_Tokens_Users_UserId]
GO
ALTER TABLE [dbo].[UserClaims]  WITH CHECK ADD  CONSTRAINT [FK_UserClaims_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserClaims] CHECK CONSTRAINT [FK_UserClaims_Users_UserId]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_Roles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_Roles_RoleId]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_Users_UserId]
GO
ALTER TABLE [HangFire].[JobParameter]  WITH CHECK ADD  CONSTRAINT [FK_HangFire_JobParameter_Job] FOREIGN KEY([JobId])
REFERENCES [HangFire].[Job] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [HangFire].[JobParameter] CHECK CONSTRAINT [FK_HangFire_JobParameter_Job]
GO
ALTER TABLE [HangFire].[State]  WITH CHECK ADD  CONSTRAINT [FK_HangFire_State_Job] FOREIGN KEY([JobId])
REFERENCES [HangFire].[Job] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [HangFire].[State] CHECK CONSTRAINT [FK_HangFire_State_Job]
GO
ALTER TABLE [issuetracker].[Comments]  WITH CHECK ADD  CONSTRAINT [FK_Comments_Comments_ParentCommentId] FOREIGN KEY([ParentCommentId])
REFERENCES [issuetracker].[Comments] ([Id])
GO
ALTER TABLE [issuetracker].[Comments] CHECK CONSTRAINT [FK_Comments_Comments_ParentCommentId]
GO
ALTER TABLE [issuetracker].[Comments]  WITH CHECK ADD  CONSTRAINT [FK_Comments_Issues_IssueId] FOREIGN KEY([IssueId])
REFERENCES [issuetracker].[Issues] ([Id])
GO
ALTER TABLE [issuetracker].[Comments] CHECK CONSTRAINT [FK_Comments_Issues_IssueId]
GO
ALTER TABLE [issuetracker].[Comments]  WITH CHECK ADD  CONSTRAINT [FK_Comments_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [issuetracker].[Comments] CHECK CONSTRAINT [FK_Comments_Locations_TenantId]
GO
ALTER TABLE [issuetracker].[Comments]  WITH CHECK ADD  CONSTRAINT [FK_Comments_Users_CommentedById] FOREIGN KEY([CommentedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [issuetracker].[Comments] CHECK CONSTRAINT [FK_Comments_Users_CommentedById]
GO
ALTER TABLE [issuetracker].[Issues]  WITH CHECK ADD  CONSTRAINT [FK_Issues_Issues_DuplicateIssueId] FOREIGN KEY([DuplicateIssueId])
REFERENCES [issuetracker].[Issues] ([Id])
GO
ALTER TABLE [issuetracker].[Issues] CHECK CONSTRAINT [FK_Issues_Issues_DuplicateIssueId]
GO
ALTER TABLE [issuetracker].[Issues]  WITH CHECK ADD  CONSTRAINT [FK_Issues_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [issuetracker].[Issues] CHECK CONSTRAINT [FK_Issues_Locations_TenantId]
GO
ALTER TABLE [issuetracker].[Issues]  WITH CHECK ADD  CONSTRAINT [FK_Issues_Users_LastStatusChangedById] FOREIGN KEY([LastStatusChangedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [issuetracker].[Issues] CHECK CONSTRAINT [FK_Issues_Users_LastStatusChangedById]
GO
ALTER TABLE [issuetracker].[Issues]  WITH CHECK ADD  CONSTRAINT [FK_Issues_Users_ReportedById] FOREIGN KEY([ReportedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [issuetracker].[Issues] CHECK CONSTRAINT [FK_Issues_Users_ReportedById]
GO
ALTER TABLE [issuetracker].[IssueTags]  WITH CHECK ADD  CONSTRAINT [FK_IssueTags_Issues_IssueId] FOREIGN KEY([IssueId])
REFERENCES [issuetracker].[Issues] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [issuetracker].[IssueTags] CHECK CONSTRAINT [FK_IssueTags_Issues_IssueId]
GO
ALTER TABLE [issuetracker].[IssueTags]  WITH CHECK ADD  CONSTRAINT [FK_IssueTags_Tags_TagId] FOREIGN KEY([TagId])
REFERENCES [issuetracker].[Tags] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [issuetracker].[IssueTags] CHECK CONSTRAINT [FK_IssueTags_Tags_TagId]
GO
ALTER TABLE [issuetracker].[IssueTags]  WITH CHECK ADD  CONSTRAINT [FK_IssueTags_Users_TagOwnerId] FOREIGN KEY([TagOwnerId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [issuetracker].[IssueTags] CHECK CONSTRAINT [FK_IssueTags_Users_TagOwnerId]
GO
ALTER TABLE [keabis].[Attachments]  WITH CHECK ADD  CONSTRAINT [FK_Attachments_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[Attachments] CHECK CONSTRAINT [FK_Attachments_Users_CreatedById]
GO
ALTER TABLE [keabis].[Attachments]  WITH CHECK ADD  CONSTRAINT [FK_Attachments_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[Attachments] CHECK CONSTRAINT [FK_Attachments_Users_ModifiedById]
GO
ALTER TABLE [keabis].[EmailConfigurations]  WITH CHECK ADD  CONSTRAINT [FK_EmailConfigurations_Organizations_OrganizationId] FOREIGN KEY([OrganizationId])
REFERENCES [dbo].[Organizations] ([Id])
GO
ALTER TABLE [keabis].[EmailConfigurations] CHECK CONSTRAINT [FK_EmailConfigurations_Organizations_OrganizationId]
GO
ALTER TABLE [keabis].[EmailTemplates]  WITH CHECK ADD  CONSTRAINT [FK_EmailTemplates_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [keabis].[EmailTemplates] CHECK CONSTRAINT [FK_EmailTemplates_Locations_TenantId]
GO
ALTER TABLE [keabis].[EmailTemplates]  WITH CHECK ADD  CONSTRAINT [FK_EmailTemplates_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[EmailTemplates] CHECK CONSTRAINT [FK_EmailTemplates_Users_CreatedById]
GO
ALTER TABLE [keabis].[EmailTemplates]  WITH CHECK ADD  CONSTRAINT [FK_EmailTemplates_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[EmailTemplates] CHECK CONSTRAINT [FK_EmailTemplates_Users_ModifiedById]
GO
ALTER TABLE [keabis].[ExternalApplications]  WITH CHECK ADD  CONSTRAINT [FK_ExternalApplications_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [keabis].[ExternalApplications] CHECK CONSTRAINT [FK_ExternalApplications_Locations_TenantId]
GO
ALTER TABLE [keabis].[ExternalApplications]  WITH CHECK ADD  CONSTRAINT [FK_ExternalApplications_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[ExternalApplications] CHECK CONSTRAINT [FK_ExternalApplications_Users_CreatedById]
GO
ALTER TABLE [keabis].[ExternalApplications]  WITH CHECK ADD  CONSTRAINT [FK_ExternalApplications_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[ExternalApplications] CHECK CONSTRAINT [FK_ExternalApplications_Users_ModifiedById]
GO
ALTER TABLE [keabis].[FirebaseTokens]  WITH CHECK ADD  CONSTRAINT [FK_FirebaseTokens_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [keabis].[FirebaseTokens] CHECK CONSTRAINT [FK_FirebaseTokens_Users_UserId]
GO
ALTER TABLE [keabis].[OTPRequestLogs]  WITH CHECK ADD  CONSTRAINT [FK_OTPRequestLogs_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[OTPRequestLogs] CHECK CONSTRAINT [FK_OTPRequestLogs_Users_UserId]
GO
ALTER TABLE [keabis].[PasswordChangeLogs]  WITH CHECK ADD  CONSTRAINT [FK_PasswordChangeLogs_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[PasswordChangeLogs] CHECK CONSTRAINT [FK_PasswordChangeLogs_Users_UserId]
GO
ALTER TABLE [keabis].[RolePrivileges]  WITH CHECK ADD  CONSTRAINT [FK_RolePrivileges_AppFeatures_FeatureId] FOREIGN KEY([FeatureId])
REFERENCES [keabis].[AppFeatures] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [keabis].[RolePrivileges] CHECK CONSTRAINT [FK_RolePrivileges_AppFeatures_FeatureId]
GO
ALTER TABLE [keabis].[RolePrivileges]  WITH CHECK ADD  CONSTRAINT [FK_RolePrivileges_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [keabis].[RolePrivileges] CHECK CONSTRAINT [FK_RolePrivileges_Locations_TenantId]
GO
ALTER TABLE [keabis].[RolePrivileges]  WITH CHECK ADD  CONSTRAINT [FK_RolePrivileges_Roles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [keabis].[RolePrivileges] CHECK CONSTRAINT [FK_RolePrivileges_Roles_RoleId]
GO
ALTER TABLE [keabis].[RolePrivileges]  WITH CHECK ADD  CONSTRAINT [FK_RolePrivileges_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[RolePrivileges] CHECK CONSTRAINT [FK_RolePrivileges_Users_CreatedById]
GO
ALTER TABLE [keabis].[RolePrivileges]  WITH CHECK ADD  CONSTRAINT [FK_RolePrivileges_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [keabis].[RolePrivileges] CHECK CONSTRAINT [FK_RolePrivileges_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[AssignFieldLocation]  WITH CHECK ADD  CONSTRAINT [FK_AssignFieldLocation_DynamicField_DynamicFieldId] FOREIGN KEY([DynamicFieldId])
REFERENCES [Visitor].[DynamicField] ([Id])
GO
ALTER TABLE [Visitor].[AssignFieldLocation] CHECK CONSTRAINT [FK_AssignFieldLocation_DynamicField_DynamicFieldId]
GO
ALTER TABLE [Visitor].[AssignFieldLocation]  WITH CHECK ADD  CONSTRAINT [FK_AssignFieldLocation_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[AssignFieldLocation] CHECK CONSTRAINT [FK_AssignFieldLocation_Locations_TenantId]
GO
ALTER TABLE [Visitor].[AssignFieldLocation]  WITH CHECK ADD  CONSTRAINT [FK_AssignFieldLocation_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[AssignFieldLocation] CHECK CONSTRAINT [FK_AssignFieldLocation_Users_CreatedById]
GO
ALTER TABLE [Visitor].[AssignFieldLocation]  WITH CHECK ADD  CONSTRAINT [FK_AssignFieldLocation_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[AssignFieldLocation] CHECK CONSTRAINT [FK_AssignFieldLocation_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[DynamicField]  WITH CHECK ADD  CONSTRAINT [FK_DynamicField_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[DynamicField] CHECK CONSTRAINT [FK_DynamicField_Locations_TenantId]
GO
ALTER TABLE [Visitor].[DynamicField]  WITH CHECK ADD  CONSTRAINT [FK_DynamicField_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[DynamicField] CHECK CONSTRAINT [FK_DynamicField_Users_CreatedById]
GO
ALTER TABLE [Visitor].[DynamicField]  WITH CHECK ADD  CONSTRAINT [FK_DynamicField_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[DynamicField] CHECK CONSTRAINT [FK_DynamicField_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[DynamicFieldOption]  WITH CHECK ADD  CONSTRAINT [FK_DynamicFieldOption_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[DynamicFieldOption] CHECK CONSTRAINT [FK_DynamicFieldOption_Locations_TenantId]
GO
ALTER TABLE [Visitor].[DynamicFieldOption]  WITH CHECK ADD  CONSTRAINT [FK_DynamicFieldOption_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[DynamicFieldOption] CHECK CONSTRAINT [FK_DynamicFieldOption_Users_CreatedById]
GO
ALTER TABLE [Visitor].[DynamicFieldOption]  WITH CHECK ADD  CONSTRAINT [FK_DynamicFieldOption_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[DynamicFieldOption] CHECK CONSTRAINT [FK_DynamicFieldOption_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[EmployeeIdCard]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeIdCard_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[EmployeeIdCard] CHECK CONSTRAINT [FK_EmployeeIdCard_Locations_TenantId]
GO
ALTER TABLE [Visitor].[EmployeeIdCard]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeIdCard_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[EmployeeIdCard] CHECK CONSTRAINT [FK_EmployeeIdCard_Users_CreatedById]
GO
ALTER TABLE [Visitor].[EmployeeIdCard]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeIdCard_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[EmployeeIdCard] CHECK CONSTRAINT [FK_EmployeeIdCard_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[LocationDetails]  WITH CHECK ADD  CONSTRAINT [FK_LocationDetails_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[LocationDetails] CHECK CONSTRAINT [FK_LocationDetails_Locations_TenantId]
GO
ALTER TABLE [Visitor].[LocationDetails]  WITH CHECK ADD  CONSTRAINT [FK_LocationDetails_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[LocationDetails] CHECK CONSTRAINT [FK_LocationDetails_Users_CreatedById]
GO
ALTER TABLE [Visitor].[LocationDetails]  WITH CHECK ADD  CONSTRAINT [FK_LocationDetails_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[LocationDetails] CHECK CONSTRAINT [FK_LocationDetails_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[MasteField]  WITH CHECK ADD  CONSTRAINT [FK_MasteField_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[MasteField] CHECK CONSTRAINT [FK_MasteField_Locations_TenantId]
GO
ALTER TABLE [Visitor].[MasteField]  WITH CHECK ADD  CONSTRAINT [FK_MasteField_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[MasteField] CHECK CONSTRAINT [FK_MasteField_Users_CreatedById]
GO
ALTER TABLE [Visitor].[MasteField]  WITH CHECK ADD  CONSTRAINT [FK_MasteField_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[MasteField] CHECK CONSTRAINT [FK_MasteField_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[SiteVisitor]  WITH CHECK ADD  CONSTRAINT [FK_SiteVisitor_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[SiteVisitor] CHECK CONSTRAINT [FK_SiteVisitor_Locations_TenantId]
GO
ALTER TABLE [Visitor].[SiteVisitor]  WITH CHECK ADD  CONSTRAINT [FK_SiteVisitor_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[SiteVisitor] CHECK CONSTRAINT [FK_SiteVisitor_Users_CreatedById]
GO
ALTER TABLE [Visitor].[SiteVisitor]  WITH CHECK ADD  CONSTRAINT [FK_SiteVisitor_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[SiteVisitor] CHECK CONSTRAINT [FK_SiteVisitor_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[SourceData]  WITH CHECK ADD  CONSTRAINT [FK_SourceData_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[SourceData] CHECK CONSTRAINT [FK_SourceData_Locations_TenantId]
GO
ALTER TABLE [Visitor].[SourceData]  WITH CHECK ADD  CONSTRAINT [FK_SourceData_SourceType_SourceTypeId] FOREIGN KEY([SourceTypeId])
REFERENCES [Visitor].[SourceType] ([Id])
GO
ALTER TABLE [Visitor].[SourceData] CHECK CONSTRAINT [FK_SourceData_SourceType_SourceTypeId]
GO
ALTER TABLE [Visitor].[SourceData]  WITH CHECK ADD  CONSTRAINT [FK_SourceData_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[SourceData] CHECK CONSTRAINT [FK_SourceData_Users_CreatedById]
GO
ALTER TABLE [Visitor].[SourceData]  WITH CHECK ADD  CONSTRAINT [FK_SourceData_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[SourceData] CHECK CONSTRAINT [FK_SourceData_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[SourceType]  WITH CHECK ADD  CONSTRAINT [FK_SourceType_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[SourceType] CHECK CONSTRAINT [FK_SourceType_Locations_TenantId]
GO
ALTER TABLE [Visitor].[SourceType]  WITH CHECK ADD  CONSTRAINT [FK_SourceType_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[SourceType] CHECK CONSTRAINT [FK_SourceType_Users_CreatedById]
GO
ALTER TABLE [Visitor].[SourceType]  WITH CHECK ADD  CONSTRAINT [FK_SourceType_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[SourceType] CHECK CONSTRAINT [FK_SourceType_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[VisitorDataCollection]  WITH CHECK ADD  CONSTRAINT [FK_VisitorDataCollection_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[VisitorDataCollection] CHECK CONSTRAINT [FK_VisitorDataCollection_Locations_TenantId]
GO
ALTER TABLE [Visitor].[VisitorDataCollection]  WITH CHECK ADD  CONSTRAINT [FK_VisitorDataCollection_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[VisitorDataCollection] CHECK CONSTRAINT [FK_VisitorDataCollection_Users_CreatedById]
GO
ALTER TABLE [Visitor].[VisitorDataCollection]  WITH CHECK ADD  CONSTRAINT [FK_VisitorDataCollection_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[VisitorDataCollection] CHECK CONSTRAINT [FK_VisitorDataCollection_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[VisitorHeader]  WITH CHECK ADD  CONSTRAINT [FK_VisitorHeader_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[VisitorHeader] CHECK CONSTRAINT [FK_VisitorHeader_Locations_TenantId]
GO
ALTER TABLE [Visitor].[VisitorHeader]  WITH CHECK ADD  CONSTRAINT [FK_VisitorHeader_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[VisitorHeader] CHECK CONSTRAINT [FK_VisitorHeader_Users_CreatedById]
GO
ALTER TABLE [Visitor].[VisitorHeader]  WITH CHECK ADD  CONSTRAINT [FK_VisitorHeader_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[VisitorHeader] CHECK CONSTRAINT [FK_VisitorHeader_Users_ModifiedById]
GO
ALTER TABLE [Visitor].[VisitorMenu]  WITH CHECK ADD  CONSTRAINT [FK_VisitorMenu_Locations_TenantId] FOREIGN KEY([TenantId])
REFERENCES [dbo].[Locations] ([Id])
GO
ALTER TABLE [Visitor].[VisitorMenu] CHECK CONSTRAINT [FK_VisitorMenu_Locations_TenantId]
GO
ALTER TABLE [Visitor].[VisitorMenu]  WITH CHECK ADD  CONSTRAINT [FK_VisitorMenu_Users_CreatedById] FOREIGN KEY([CreatedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[VisitorMenu] CHECK CONSTRAINT [FK_VisitorMenu_Users_CreatedById]
GO
ALTER TABLE [Visitor].[VisitorMenu]  WITH CHECK ADD  CONSTRAINT [FK_VisitorMenu_Users_ModifiedById] FOREIGN KEY([ModifiedById])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [Visitor].[VisitorMenu] CHECK CONSTRAINT [FK_VisitorMenu_Users_ModifiedById]
GO
/****** Object:  StoredProcedure [dbo].[MNT_ReIndexLocations]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[MNT_ReIndexLocations](@tenantId nvarchar(50)=null)
as
begin
DECLARE @CurrentId nvarchar(50)
DECLARE @CurrentParentId nvarchar(50)
DECLARE @SafeGuard INTEGER
DECLARE @myLeft INTEGER
SET @SafeGuard = 100000
if(@tenantId is null)
begin
declare @counter int=0;
DECLARE db_cursor CURSOR FOR
select distinct Id from Organizations;
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @tenantId

WHILE @@FETCH_STATUS = 0
BEGIN
print 'Processing for ' + @tenantId;
DECLARE @StartTime datetime
DECLARE @EndTime datetime
SELECT @StartTime=GETDATE() 
    exec MNT_ReIndexLocations @tenantId;
	SELECT @EndTime=GETDATE()
	print cast(DATEDIFF(MS,@StartTime,@EndTime) as nvarchar(50)) + 'ms';
    FETCH NEXT FROM db_cursor INTO @tenantId
	set @counter = @counter + 1;
	print cast(@counter as nvarchar(50)) + ' record(s) processed';
END

CLOSE db_cursor
DEALLOCATE db_cursor
return;
end
declare @OrganizationId nvarchar(50)=(select OrganizationId from Locations where Id=@tenantId)

/* Initialize */
UPDATE  l set LeftExtent=1, RightExtent=2 from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id where lt.OrganizationId=@OrganizationId and ParentLocationId is null;

UPDATE  l set LeftExtent=0, RightExtent=0 from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id where lt.OrganizationId=@OrganizationId and ParentLocationId is not null;

WHILE EXISTS (SELECT 1 FROM Locations l join LocationTypes lt on l.LocationTypeId=lt.Id WHERE lt.OrganizationId=@OrganizationId and LeftExtent=0) AND @SafeGuard > 0
BEGIN
  SELECT @CurrentId = MAX(nc.Id) from Locations nc
          INNER JOIN Locations nc2 ON nc2.Id = nc.ParentLocationId join LocationTypes lt on nc.LocationTypeId=lt.Id
  WHERE  lt.OrganizationId=@OrganizationId and nc.LeftExtent=0 AND nc2.LeftExtent <> 0

  SELECT  @CurrentParentId = ParentLocationId
  FROM    Locations
  WHERE   Id = @CurrentId

  SELECT  @myLeft = LeftExtent
  FROM    Locations
  WHERE   Id = @CurrentParentId

  UPDATE l SET RightExtent = RightExtent + 2 from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id WHERE RightExtent > @myLeft;
  UPDATE l SET LeftExtent = LeftExtent + 2 from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id WHERE LeftExtent > @myLeft;
  UPDATE l SET LeftExtent = @myLeft + 1, RightExtent = @myLeft + 2 from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id WHERE l.Id = @CurrentId

  SET @SafeGuard = @SafeGuard - 1
END


--select * from LocationTypes
--SELECT * FROM @nested_category ORDER BY category_id

--SELECT  COUNT(node.name), node.name, MIN(node.lft)
--FROM    @nested_category AS node,
--        @nested_category AS parent
--WHERE   node.lft BETWEEN parent.lft AND parent.rgt
--GROUP BY 
--        node.name
--ORDER BY
--        3, 1
end
GO
/****** Object:  StoredProcedure [dbo].[USP_AddLocationType]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[USP_AddLocationType]
	-- Add the parameters for the stored procedure here
	@Name nvarchar(50), @tenantId nvarchar(50), @userId nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @Id nvarchar(50)=replace(cast(newid() as nvarchar(50)),'-','');
	declare @Level int, @OrganizationId nvarchar(50);
	select @Level=isnull(max(Level),0) + 1, @OrganizationId=l.OrganizationId from Locations l left join LocationTypes lt on l.OrganizationId=lt.OrganizationId where l.Id=@tenantId group by l.OrganizationId;
		INSERT INTO LocationTypes (Id, Name, Level, CreatedById, CreatedOn, ModifiedById, ModifiedOn, OrganizationId, IsAdminLevel)
		VALUES (@Id, @Name, @Level, @userId, GETUTCDATE(), @userId, GETUTCDATE(), @OrganizationId, 0);
select @Id as Id, @Name as Name, @Level as Level;

END

GO
/****** Object:  StoredProcedure [dbo].[USP_CheckSiteCodeAvailabilityInOrganization]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USP_CheckSiteCodeAvailabilityInOrganization](@tenantId nvarchar(50), @code nvarchar(50), @id nvarchar(50)) as
begin
select count(*) from Locations l join Locations l2 on l.OrganizationId=l2.OrganizationId where l.Id=@tenantId
and
l2.Code=@code and l2.Id != @id and
l2.IsActive=1;

end

GO
/****** Object:  StoredProcedure [dbo].[USP_CheckSiteNameAvailabilityInOrganization]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USP_CheckSiteNameAvailabilityInOrganization](@tenantId nvarchar(50), @name nvarchar(50), @id nvarchar(50)) as
begin
select count(*) from Locations l join Locations l2 on l.OrganizationId=l2.OrganizationId where l.Id=@tenantId
and
l2.Name=@name and l2.Id != @id and
l2.IsActive=1;

end

GO
/****** Object:  StoredProcedure [dbo].[USP_Dashboard_GetKpi]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USP_Dashboard_GetKpi](
@name nvarchar(50), 
@periodicity int, 
@granularity int, 
@locationId nvarchar(50), 
@tenantId nvarchar(50), 
@userId nvarchar(50), 
@aggregate int = 0, 
@startDateTime datetime=null, 
@endDateTime datetime=null, @category_list id_list READONLY)  
as  
begin  
		if(@startDateTime is not null and @endDateTime is not null)  
		set @endDateTime = DATEADD(second, -1, DATEDIFF(day, 0, @endDateTime) + 1);  
		declare @value int=0;  
		declare @previousValue int=0;  
		declare @previosStartDateTime datetime;  
		if(@endDateTime is null or @startDateTime is null)  
		begin  
		set @endDateTime = dbo.UDF_GetEndDateFromPeriodicity(@periodicity);  
		set @startDateTime=dbo.UDF_ParseStartDateFromPeriodicityGranularity(@periodicity,@endDateTime);  
		end  
  
		--set @previosStartDateTime=dbo.UDF_ParseStartDateFromPeriodicityGranularity(@periodicity,@startDateTime);  
		declare @categoryCount int=(select count(*) from @category_list);  
		set @startDateTime=dateadd(minute,-330,@startDateTime);  
		set @endDateTime=dateadd(minute,-330,@endDateTime);  
		set @value = 1;  
  
		 --periodicity:  
		 --Custom = 0, Last15Minutes, Last30Minutes, LastHour, Last6Hours, Last12Hours, Last24Hours, Last48Hours, Last3Days, Last7Days, Last30Days, Month, Quarter, HalfYear, Year  
  
		 --Aggregate:  
		 --Total = 0, Avg, Min, Max  
		 if(@name = 'testdata')  
		 begin  
		        set @value = 100;   
		 end  


		select @value as Value, @previousValue as PreviousValue;  
end  
  
  
  
  
GO
/****** Object:  StoredProcedure [dbo].[USP_Dashboard_GetTabularOrGraphData]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USP_Dashboard_GetTabularOrGraphData](@metadataId nvarchar(50), @name nvarchar(50), @periodicity int, @granularity int, @locationId nvarchar(50), @tenantId nvarchar(50), @userId nvarchar(50), @startDateTime datetime=null, @endDateTime datetime=null, @category_list id_list READONLY)
as
begin
if(@startDateTime is not null and @endDateTime is not null)
set @endDateTime = DATEADD(second, -1, DATEDIFF(day, 0, @endDateTime) + 1);
if(@endDateTime is null or @startDateTime is null)
begin
set @endDateTime = dbo.UDF_GetEndDateFromPeriodicity(@periodicity);
set @startDateTime=dbo.UDF_ParseStartDateFromPeriodicityGranularity(@periodicity,@endDateTime);
end
set @endDateTime = DATEADD(second, -1, DATEDIFF(day, 0, @endDateTime) + 1);
declare @queryCount int = 0, @maxQueryCount int = 12;
if(@granularity is null or @granularity=0)
set @maxQueryCount = 1;
while(@queryCount < @maxQueryCount and @endDateTime > @startDateTime)
begin
set @queryCount = @queryCount + 1;
declare @seriesStartDate datetime, @seriesEndDate datetime= @endDateTime;
if(@granularity > 0)
begin
	set @endDateTime=dbo.UDF_ParseStartDateFromPeriodicityGranularity(@granularity,@endDateTime);
	set @seriesStartDate=@endDateTime;
end
else
begin
	set @seriesStartDate=dateadd(minute,-330,@startDateTime);
	set @seriesEndDate=dateadd(minute,-330,@endDateTime);
end
declare @categoryCount int=(select count(*) from @category_list);
if(@granularity is null or @granularity=0)
begin
	declare @diff int = datediff(minute,@startDateTime,@endDateTime);
	set @granularity=case when @diff < 50 then 101 when @diff < 24*60 then 201 else 301 end; 
end

	

end


end
GO
/****** Object:  StoredProcedure [dbo].[USP_DeleteLocation]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USP_DeleteLocation](@id nvarchar(50))
as
begin
declare @leftExtent int, @rightExtent int;
select @leftExtent=LeftExtent, @rightExtent=RightExtent from Locations where Id=@id;
declare @organizationId nvarchar(50)=(select OrganizationId from Locations where Id=@id);
begin transaction
begin try
delete from Locations where Id=@id and OrganizationId=@organizationId;
update Locations set LeftExtent=LeftExtent-2, RightExtent=RightExtent-2 where RightExtent > @rightExtent
commit transaction;
end try
begin catch
rollback transaction;
throw;
end catch
end
GO
/****** Object:  StoredProcedure [dbo].[USP_DeleteLocationLeafNode]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USP_DeleteLocationLeafNode](@locationId nvarchar(50))
as
begin
BEGIN TRANSACTION;  
declare @organizationId nvarchar(50), @leftExtent int, @rightExtent int;
select @organizationId=OrganizationId, @leftExtent=LeftExtent, @rightExtent=RightExtent from Locations where Id=@locationId and LeftExtent=RightExtent-1;
update Locations set LeftExtent=LeftExtent-2 where OrganizationId=@organizationId and LeftExtent >@leftExtent;
update Locations set RightExtent=RightExtent-2 where OrganizationId=@organizationId and RightExtent >@rightExtent;
delete from Locations where Id=@locationId;
commit;
end
GO
/****** Object:  StoredProcedure [dbo].[USP_GetAccessibleLocations]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USP_GetAccessibleLocations](@userId nvarchar(50))
as
begin
select distinct l.Id, l.Name, l.ImageUrl from Locations l join
(select l.OrganizationId, l.LeftExtent as RootLeftExtent, l.RightExtent as RootRightExtent from Locations l join UserRoles ur  on l.Id=ur.TenantId where @userId='BUILTIN_USER_SUPER_ADMIN' OR ur.UserId=@userId) lr on l.Organizationid=lr.OrganizationId and l.LeftExtent between lr.RootLeftExtent and lr.RootRightExtent join LocationTypes lt on l.LocationTypeId=lt.Id where l.LeftExtent=l.RightExtent-1
order by l.Name
end


GO
/****** Object:  StoredProcedure [dbo].[USP_GetAuthScopedLocations]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[USP_GetAuthScopedLocations](@userId nvarchar(50))
as
begin
--select distinct l.Id, l.Name, l.ImageUrl from Locations l join
--(select l.OrganizationId, l.LeftExtent as RootLeftExtent, l.RightExtent as RootRightExtent from Locations l join UserRoles ur  on l.Id=ur.TenantId where @userId='BUILTIN_USER_SUPER_ADMIN' OR ur.UserId=@userId) lr on l.Organizationid=lr.OrganizationId and l.LeftExtent between lr.RootLeftExtent and lr.RootRightExtent join LocationTypes lt on l.LocationTypeId=lt.Id where l.LeftExtent=l.RightExtent-1

--select distinct l.Id, l.Name, l.ImageUrl from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id left join UserClaims uc on l.Id=uc.ClaimValue where lt.IsAdminLevel=1 and l.IsActive=1 and (@userId='BUILTIN_USER_SUPER_ADMIN' or uc.ClaimType='Location' and uc.UserId=@userId)
select distinct l.Id, l.Name, l.ImageUrl, l.ParentLocationId, lt.Name as LocationTypeName, lt.Level, l.LeftExtent, l.OrganizationId from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id join (
select min(ltmin.Level) LevelMin, ltmin.OrganizationId, max(ltmax.Level) LevelMax from LocationTypes ltmin join LocationTypes ltmax on ltmin.OrganizationId=ltmax.OrganizationId join Locations l on ltmin.Id=l.LocationTypeId
left join UserClaims uc on l.Id=uc.ClaimValue and uc.ClaimType='Location'
where l.IsActive=1 and ltmax.IsAdminLevel=1 and (@userId='BUILTIN_USER_SUPER_ADMIN' or uc.ClaimType='Location' and uc.UserId=@userId)
group by ltmin.OrganizationId) q on l.OrganizationId=q.OrganizationId and lt.Level >= q.LevelMin and lt.Level <= q.LevelMax
left join UserClaims uc on l.Id=uc.ClaimValue and uc.ClaimType='Location'
where l.IsActive=1 and (@userId='BUILTIN_USER_SUPER_ADMIN' or uc.ClaimType='Location' and uc.UserId=@userId)
order by l.LeftExtent
end



GO
/****** Object:  StoredProcedure [dbo].[USP_InsertLocation]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[USP_InsertLocation]
(
	@Id nvarchar (50),
	@Name nvarchar (50),
	@Code nvarchar (50),
	@LocationTypeId nvarchar (50),
	@ParentLocationId nvarchar (50),
	@ContactPersonName nvarchar(50),
	@PhoneNumber nvarchar(50),
	@ImageUrl nvarchar(256),
	@Email nvarchar(50),
	@Address nvarchar(200),
	@BillingAddress nvarchar(200),
	--@CanAddManualAttendance bit,
	--@IsPayableOT bit,
	--@IsRegistrationAllowedFromDevice bit,
	@UserId nvarchar(50),
	@TenantId nvarchar(50),
	@emailVerificationHash nvarchar(200)
)

AS
begin
declare @sendEmail bit=0;
BEGIN TRANSACTION;
BEGIN TRY
	declare @LeftExtent int=0, @existingEmail nvarchar(50);
	declare @OrganizationId nvarchar(50)=(select OrganizationId from Locations l where l.Id=@TenantId);
	if(@OrganizationId is null)
	begin
	declare @msg nvarchar(max) = 'Could not find organization for TenantId ' + isnull(@TenantId,'(Not Specified)')
	RAISERROR (15600,-1,-1, @msg);  
	end
	if(@Email is null)
	begin
		select @Email=Email, @ContactPersonName=ContactPersonName, @PhoneNumber=PhoneNumber, @Address=Address, @BillingAddress=BillingAddress from Locations where Id=@ParentLocationId
	end
	
	SELECT @LeftExtent=RightExtent, @existingEmail=Email FROM Locations l join LocationTypes lt on l.LocationTypeId=lt.Id WHERE lt.OrganizationId=@OrganizationId and l.Id = @ParentLocationId;
		UPDATE l SET RightExtent = RightExtent + 2 from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id WHERE lt.OrganizationId=@OrganizationId and RightExtent >= @LeftExtent;
		UPDATE l SET LeftExtent = LeftExtent + 2  from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id WHERE lt.OrganizationId=@OrganizationId and LeftExtent > @LeftExtent;
		INSERT INTO Locations (Id, Name, Code, LocationTypeId, ParentLocationId, ImageUrl, ContactPersonName, PhoneNumber, Email, Address, BillingAddress, OrganizationId, CreatedById, CreatedOn, ModifiedById, ModifiedOn, IsActive, LeftExtent, RightExtent) 
		VALUES  (@Id, @Name, @Code, @LocationTypeId, @ParentLocationId, @ImageUrl, @ContactPersonName, @PhoneNumber, @Email, @Address, @BillingAddress, @OrganizationId, @UserId, GETUTCDATE(), @UserId, GETUTCDATE(), 1, @LeftExtent, @LeftExtent + 1)

		if(@existingEmail is not null and @existingEmail != @Email)
		begin
		update l set Email=@Email from Locations l join dbo.UDF_GetAllLocationsUnderParentId(@Id,null) l2 on l.Id=l2.LocationId where l.Email=@existingEmail;
		end

	declare @newUserId nvarchar(50)=(select Id from Users where Email=@Email);
	if(@newUserId is null)
	begin
	--Creating new user
	set @newUserId=@Id;
	insert into Users (Id, UserName, DisplayName, PhoneNumber, Email, DefaultTenantId, IsBuiltin, PhoneNumberVerified, EmailVerified, EmailVerificationHash, EmailVerificationExpiryUtc) 
		values(@newUserId, @Id, @ContactPersonName, @PhoneNumber, @Email, @Id, 0, 0, 0, @emailVerificationHash, DATEADD(hour,12,getutcdate()))
		set @sendEmail=1;
	end
	--Assigning admin role for new location to user
	Insert into UserRoles(UserId, RoleId, TenantId) select @newUserId, Id, @Id from Roles where Name='Admin';

	--Assigning current location claim to user
	insert into UserClaims(UserId, ClaimType, ClaimValue)
	values(@newUserId, 'Location', @Id)

	--Assigning claims for newly created location to org level users
	insert into UserClaims(UserId, ClaimType, ClaimValue)
	select distinct u.Id, 'Location', @Id from Users u join UserRoles ur on u.Id=ur.UserId join Roles r on ur.RoleId=r.Id join UserClaims uc on u.Id=uc.UserId and uc.ClaimType='Location' left join UserClaims uc2 on uc.UserId=uc2.UserId and uc.ClaimType=uc2.ClaimType and uc.ClaimValue=uc2.ClaimValue
	where isnull(u.IsDeleted,0)=0 and r.RoleLevel=1 and uc.ClaimValue=@OrganizationId and uc2.ClaimType is null and uc2.ClaimValue is null and uc2.UserId is null;

	COMMIT TRANSACTION;
	select @sendEmail;
END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;
	throw;
END CATCH;
/*DROP PROC dbo.USP_InsertLocation*/
end


GO
/****** Object:  StoredProcedure [dbo].[USP_ListLocations]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [dbo].[USP_ListLocations](
@tenantId nvarchar(50),
@userId nvarchar(50),
@type int=0, --All=0, UserAssignable=1, SubLocation=2, BelowTenantId=3
@parentId nvarchar(50)=null,
@withParent bit = 0
)
as
begin
declare @organizationId nvarchar(50), @adminLevel int, @userLevel int, @tenantLevel int, @tenantLeftExtent int, @tenantRightExtent int;
select @organizationId=l.OrganizationId, @adminLevel=lt.Level, @userLevel=r.RoleLevel from Locations l join LocationTypes lt on l.OrganizationId=lt.OrganizationId, UserRoles ur, Roles r where l.Id=@tenantId and lt.IsAdminLevel=1 and ur.RoleId=r.Id and ur.UserId=@userId;
if(@type=3)
select @tenantLevel= lt.Level, @tenantLeftExtent=l.LeftExtent, @tenantRightExtent=l.RightExtent from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id where l.Id=@tenantId

if(exists(select 1 from UserRoles ur join Roles r on ur.RoleId=r.Id where ur.UserId=@userId and r.RoleLevel < 2))
begin
print 'Org manager or above';
	select distinct l.Id, l.Name, l.Code, l.ParentLocationid, l.LocationTypeId, lt.Name as LocationTypeName, lt.Level, lt.IsAdminLevel from Locations l join LocationTypes lt on l.LocationTypeId=lt.Id where l.OrganizationId=@organizationId
	and (@parentId is null or (l.ParentLocationId=@parentId or (@withParent=1 and l.Id=@parentId)))
	and (@type=0 or (@type=1 and lt.Level <=@adminLevel) or (@type=2 and lt.Level > @adminLevel)
	or (@type=3 and
	l.LeftExtent >=@tenantLeftExtent and l.RightExtent <=@tenantRightExtent and
	((@withParent=1 and lt.Level >=@tenantLevel) or (@withParent=0 and lt.Level>@tenantLevel))))
end
else
begin
print 'Admin or below';
	select distinct l.Id, l.Name, l.Code, l.ParentLocationId, l.LocationTypeId, lt.Name as LocationTypeName, lt.Level, lt.IsAdminLevel from Users u
	join UserClaims uc on u.Id=uc.UserId and uc.ClaimType='Location'
	join Locations ul on uc.ClaimValue=ul.Id
	join Locations l on ul.OrganizationId=l.OrganizationId and ul.LeftExtent <=l.LeftExtent and ul.RightExtent >=l.RightExtent
	join LocationTypes lt on l.LocationTypeId=lt.Id
	where u.Id=@userId
	and l.OrganizationId=@organizationId
	and (@parentId is null or (l.ParentLocationId=@parentId or (@withParent=1 and l.Id=@parentId)))
	and (@type=0 or (@type=1 and lt.Level <=@adminLevel) or (@type=2 and lt.Level > @adminLevel)
	or (@type=3 and
	l.LeftExtent >=@tenantLeftExtent and l.RightExtent <=@tenantRightExtent and
	((@withParent=1 and lt.Level >=@tenantLevel) or (@withParent=0 and lt.Level>@tenantLevel))))
end

end


GO
/****** Object:  StoredProcedure [dbo].[USP_ListLocationTypes]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[USP_ListLocationTypes]
	-- Add the parameters for the stored procedure here
	@tenantId nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT distinct l.Id, l.Name, l.Level, l.IsAdminLevel FROM LocationTypes l join Locations ln on l.OrganizationId=ln.OrganizationId where ln.Id=@tenantId order by l.Level
END


GO
/****** Object:  StoredProcedure [dbo].[USP_ListUsersPaged]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[USP_ListUsersPaged](@userId nvarchar(50), @tenantId nvarchar(50), @filter nvarchar(50), @offset int = 0, @pageSize int = 50, @sort nvarchar(50) = null, @descending bit = 0)
as
begin
if(@filter is not null)
set @filter = '%' + @filter + '%';
declare @canApprove bit = 0, @TotalRows int=0;
declare @myLevel int = (select min(RoleLevel) from Roles r join UserRoles ur on r.Id=ur.RoleId where ur.UserId=@userId)
--UserStatus: NeedActivation, Active, IsBlocked, IsBlacklisted
;WITH Data_CTE AS
(
select distinct u.Id, case when u.Id=u.UserName then '(Email only)' else u.UserName end as UserName, u.DisplayName, u.AvatarUrl, u.PhoneNumber, u.Email, case when u.PasswordHash is null then 0 when u.IsPermanentLockOut=1 then 2 else 1 end as UserStatus from Users	u 
join UserRoles ur on u.Id=ur.UserId 
join Roles r on ur.RoleId=r.Id
join Locations l on ur.TenantId=l.Id
join Locations l2 on l.OrganizationId=l2.OrganizationId and l2.Id=@tenantId
where u.Id != @userId and r.RoleLevel > @myLevel
), 
Count_CTE 
AS 
(
    SELECT COUNT(*) AS TotalRows FROM Data_CTE
)
select * from Data_CTE d cross join Count_CTE
order by
 case when @descending=0 then
  case
   when @sort='UserName' then UserName
   when @sort='DisplayName' then DisplayName
   when @sort='PhoneNumber' then PhoneNumber
   when @sort='Email' then Email
  end
 end asc
 , case when @descending=1 then
case
   when @sort='UserName' then UserName
   when @sort='DisplayName' then DisplayName
   when @sort='PhoneNumber' then PhoneNumber
   when @sort='Email' then Email
  end
 end asc
OFFSET @offset ROWS
 FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

end


GO
/****** Object:  StoredProcedure [dbo].[USP_SetAdminLocationType]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hussain
-- Create date: 24-05-2021
-- Description:	Sets Location Type IsAdminLevel=true and migrates all employees from lower level to current level
-- =============================================
CREATE   PROCEDURE [dbo].[USP_SetAdminLocationType] 
	-- Add the parameters for the stored procedure here
	@id nvarchar(50),
	@tenantId nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @organizationId nvarchar(50)=(select OrganizationId from Locations where Id=@tenantId);
	update LocationTypes set IsAdminLevel=(case when Id=@id then 1 else 0 end) where OrganizationId=@organizationId;
	select 0 as MigratedEmployeeCount, 0 as SkippedEmployeeCount;
END
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_DeleteDynamicInfo]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_DeleteDynamicInfo]                    
 @pDynamicId nvarchar(100),                
 @pUserId nvarchar(100),                
 @pCreatedOn datetime                    
AS                                            
BEGIN                                
                 
  IF(EXISTS(SELECT Id FROM  Visitor.DynamicField  where id=@pDynamicId and IsDeleted=0))                
  BEGIN                
   Update  Visitor.DynamicField   SET IsDeleted=1, ModifiedById=@pUserId, ModifiedOn=@pCreatedOn  WHERE id=@pDynamicId  and IsDeleted=0       
   select 1 as ResponseStatus,'Deleted Successfully' as ResponseMessage
              
   END                
 ELSE                
  BEGIN  
     select 0 as ResponseStatus,'Invalid Input' as ResponseMessage
  END                
              
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_DeletelocationInfo]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 Create procedure [dbo].[UspVisitor_DeletelocationInfo]                
 @plocationId nvarchar(100),            
 @pUserId nvarchar(100),            
 @pCreatedOn datetime                
AS                                        
BEGIN                            
	 IF(EXISTS(SELECT Id FROM [Visitor].[LocationDetails] where id=@plocationId and IsDeleted=0))            
	  BEGIN            
		   Update [Visitor].[LocationDetails] SET IsDeleted=1, ModifiedById=@pUserId, ModifiedOn=@pCreatedOn  WHERE id=@plocationId  and IsDeleted=0  
		   select 1 as ResponseStatus , 'Successfully Deleted' as ResponseMessage
        
	   END            
		ELSE            
	  BEGIN            
		  select 0 as ResponseStatus , 'Invalid Input' as ResponseMessage
	  END            
END

GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_DeleteSourceInfo]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
               
CREATE procedure [dbo].[UspVisitor_DeleteSourceInfo]                      
 @pSourceId nvarchar(100),                  
 @pUserId nvarchar(100),                  
 @pCreatedOn datetime                      
AS                                              
BEGIN                                  
                   
  IF(EXISTS(SELECT Id FROM  [Visitor].[SourceType]  where id=@pSourceId and IsDeleted=0))                  
  BEGIN                  
		Update  [Visitor].[SourceType]   SET IsDeleted=1, ModifiedById=@pUserId, ModifiedOn=@pCreatedOn  WHERE id=@pSourceId  and IsDeleted=0                  
		SELECT 1 as ResponseStatus,'Successfully Deleted' as ResponseMessage
   END                  
  ELSE                  
  BEGIN                  
	   SELECT 0 as ResponseStatus,'Invalid data' as ResponseMessage
  END                  
          
END 

GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetAssignFieldLocation]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_GetAssignFieldLocation]   
   @pTenantId nvarchar(100)
AS                                                    
BEGIN     
  
 if object_id('tempdb..#AssignField') is not null                                                                                                                        
    drop table #AssignField                                                                                                     
    create TABLE #AssignField                                                                                                                     
    (DynamicId nvarchar(100) ,DisplayText nvarchar(100), DataType nvarchar(100),DataTypeStatus int  )  

	Insert into #AssignField   
	Select D.Id as DynamicId, d.DisplayText as DisplayText,d.DataType as DataType, 2  as DataTypeStatus  from [Visitor].[DynamicField] D where IsDeleted=0   
	and D.TenantId = @pTenantId
  
    Update #AssignField set DataTypeStatus=1 where DataType in ('Textbox','Datetime')  
    select DynamicId,DisplayText,DataType,DataTypeStatus from #AssignField  
END     
 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetAssignFieldLocationByID]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_GetAssignFieldLocationByID]     
 @pVisitorType nvarchar(100),                    
 @pTenantId nvarchar(100)     
AS                                                        
BEGIN         
      
    if object_id('tempdb..#AssignField') is not null
	drop table #AssignField
	create TABLE #AssignField(DynamicId nvarchar(100) ,DisplayText nvarchar(1000), DataType nvarchar(100),DataTypeStatus int ,    
    PageNo int, SeqNo int, SourceId int, AssignFieldLocationId nvarchar(100), SourceTypeId nvarchar(100), isSelected bit )     
    
  if object_id('tempdb..#RemovedAssignField') is not null      
  drop table #RemovedAssignField      
  create TABLE #RemovedAssignField(DynamicId nvarchar(100) ,DisplayText nvarchar(1000), DataType nvarchar(100),DataTypeStatus int,PageNo int, SeqNo int)      
    
    
 Insert into #AssignField
 Select D.Id as DynamicId,d.DisplayText as DisplayText,d.Type as DataType, 2  as DataTypeStatus, 0 as PageNo,    
 0 as SeqNo, A.SourceId as SourceId, A.Id as AssignFieldLocationId, null, 0   from [Visitor].[DynamicField] D     
 Left join [Visitor].[AssignFieldLocation] A on D.Id=A.DynamicFieldId    
 Where D.IsDeleted=0  and  D.TenantId = @pTenantId    
     
    Update #AssignField set DataTypeStatus=1 where DataType in ('textbox','datetime picker','multiline')      
    Update #AssignField set SourceId=null where  SourceId!=@pVisitorType    
    
 Insert into #RemovedAssignField     
 SELECT DISTINCT DynamicId, DisplayText, DataType,DataTypeStatus, PageNo ,SeqNo  FROM #AssignField;    
    
 Alter table #RemovedAssignField add AssignFieldLocationId nvarchar(100)    
 Alter table #RemovedAssignField add SourceTypeId nvarchar(100)    
 Alter table #RemovedAssignField add isSelected bit    
    
 Update T set AssignFieldLocationId=a.Id, t.PageNo=A.PageId, t.SeqNo=A.SeqNo from #RemovedAssignField T     
 Inner JOIN [Visitor].[AssignFieldLocation] A on t.DynamicId=A.DynamicFieldId where a.SourceId=@pVisitorType and IsDeleted=0    
     
 Update T set SourceTypeId=D.SourceTypeId from #RemovedAssignField T     
 Inner JOIN [Visitor].DynamicFieldOption D on T.AssignFieldLocationId=D.AssignFieldLocationId where D.IsDeleted=0    
    
 Update #RemovedAssignField set isSelected=0     
 Update #RemovedAssignField set isSelected=1 where AssignFieldLocationId is not null    
    
 select * from #RemovedAssignField  order by PageNo,SeqNo  
    
    
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetDatatype]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[UspVisitor_GetDatatype]                          
       
AS                                                  
BEGIN      
    
 IF OBJECT_ID('tempdb..#tempDatatype') is not null                                                                                                      
    DROP TABLE #tempDatatype                                                                    
    CREATE TABLE  #tempDatatype                                                                                                   
    (DateTypeId  nvarchar(500),DateType nvarchar(500))         
    
  Insert into #tempDatatype values('textbox','textbox');    
  Insert into #tempDatatype values('multiline','multiline');    
  Insert into #tempDatatype values('list','list');    
  Insert into #tempDatatype values('dropdown','dropdown');    
  Insert into #tempDatatype values('datetime picker','datetime picker');    
    
  select * from #tempDatatype    
END   
  
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetDynamicField]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE procedure [dbo].[UspVisitor_GetDynamicField]                    
 @pTenantId nvarchar(100),                    
 @psearchValue nvarchar(100)                            
AS                                                      
BEGIN                                                      
  SELECT Id as DynamicId, Name as Name, DisplayText as DisplayText, IsRequired as IsRequired, Type as DateTypeId,         
  AccessId as AccessId  FROM Visitor.DynamicField where IsDeleted=0 and  TenantId=@pTenantId         
  AND  (Name like '%'+@psearchValue+'%' or DisplayText like '%'+@psearchValue+'%')  ORDER BY  DisplayId                           
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetDynamicFieldById]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[UspVisitor_GetDynamicFieldById]                                                
  @pId NVARCHAR(100)                                         
AS                                                
BEGIN                                                
   SELECT DF.Id as DynamicId, DF.Name as Name,  DF.displaytext as DisplayText,              
   DF.IsRequired as IsRequired, DF.Type as DateTypeId, DF.AccessId as AccessId        
   FROM Visitor.DynamicField DF WHERE DF.Id=@pId and  DF.IsDeleted=0           
                             
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetHomePageLocationData]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_GetHomePageLocationData]                   
   @pStatusId int ,            
   @pTenantId nvarchar(100),      
   @pUserId nvarchar(100)       
as                    
begin                    
     select Id,Title,LogoUrl,BackgroundUrl,IsOTPRequired from [Visitor].[LocationDetails] where TenantId='ORG01738739262512779'  
     select Id,Name,MenuUrl,ColorCode,TextColor from [Visitor].[VisitorMenu]   where TenantId='ORG01738739262512779' 
          
end 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetLocationById]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE procedure [dbo].[UspVisitor_GetLocationById]                                            
   @pId NVARCHAR(100)                                     
AS                                            
BEGIN                                            
   SELECT LD.Id as LocationId, LD.Name as Name,  LD.Title as Title,          
   LD.LogoUrl as LogoUrl, LD.BackgroundUrl as BackGroundUrl, LD.IsOTPRequired as IsOTPRequried ,
   LD.isPhotoUrl as IsPhotoRequired,LD.isDocumentUrl as IsDocumentRequired
   FROM [Visitor].[LocationDetails] LD WHERE LD.Id=@pId and  LD.IsDeleted=0       
                         
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetSourceType]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE procedure [dbo].[UspVisitor_GetSourceType]                  
 @pTenantId nvarchar(100),                  
 @psearchValue nvarchar(100)                          
AS                                                    
BEGIN                                                    
  SELECT Id as SourceTypeId, Name as SourceType FROM [Visitor].[SourceType] where IsDeleted=0 and  TenantId=@pTenantId       
  AND  (Name like '%'+@psearchValue+'%' )  ORDER BY ModifiedOn  desc                                 
END 

GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetSourceTypeById]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_GetSourceTypeById]                                                                
  @pSourceTypeId nvarchar(100),                        
  @pTenantId nvarchar(100)                        
AS                                                                
BEGIN                                 
        select Id as SourceTypeId, Name as SourceType  from [Visitor].[SourceType] where TenantId=@pTenantId and IsDeleted=0 and id=@pSourceTypeId             
                 
        select SD.Id as SourceDataId, SD.Name as sourceData,sd.IsTriggerNotification as IsSelected  from [Visitor].[SourceData]  SD                            
        where SD.IsDeleted=0 AND SD.SourceTypeId=@pSourceTypeId    order by sd.IsTriggerNotification desc                       
    
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetTitleHeader]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE procedure [dbo].[UspVisitor_GetTitleHeader]                    
 @pTenantId nvarchar(100),                    
 @psearchValue nvarchar(100)                            
AS                                                      
BEGIN                                                      
  SELECT Id as TitleId, PageId as PageId, PageTitle as TitleName, Header1 as Description  FROM [Visitor].[VisitorHeader] where IsDeleted=0 and  TenantId=@pTenantId         
  AND  (PageTitle like '%'+@psearchValue+'%' or Header1 like '%' +@psearchValue+ '%' or  PageId like '%' +@psearchValue+ '%')  ORDER BY ModifiedOn  desc                                   
END   
  

GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetVisitorData]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_GetVisitorData]                
   @pMobileNo nvarchar(100) ,        
   @pTenantId   nvarchar(100)        
as                
begin                
                
       if object_id('tempdb..#tempSiteVisitorData') is not null                                          
       drop table #tempSiteVisitorData                
       create TABLE  #tempSiteVisitorData                                            
       (VisitorId nvarchar(200),IsNewUser bit,OTPValue nvarchar(100),IsCheckIn bit,Name nvarchar(100),PhotoImageUrl nvarchar(100))             
          
   if(exists (select * from [Visitor].[SiteVisitor] where PhoneNumber = @pMobileNo and TenantId = @pTenantId))              
   begin              
       declare @vVisitorId nvarchar(100)              
	   declare @vName nvarchar(100)           
	   declare @vPhotoImageUrl nvarchar(100)      
       
	   select top 1 @vVisitorId =  id,@vName = Name,@vPhotoImageUrl=PhotoImageUrl from [Visitor].[SiteVisitor] where PhoneNumber = @pMobileNo and TenantId = @pTenantId       
	   order by createdon desc        
	  if(exists (select * from [Visitor].[SiteVisitor] where id = @vVisitorId and IsCheckedOut =0 and convert(date,CheckInDateTime) = convert(date,getdate()) ))          
	  begin          
		 insert into #tempSiteVisitorData (VisitorId,IsNewUser,OTPValue,IsCheckIn,Name,PhotoImageUrl)          
			values (@vVisitorId,0,'1234',1,@vName,@vPhotoImageUrl)          
		 select VisitorId,IsNewUser,OTPValue,IsCheckIn,Name,PhotoImageUrl from #tempSiteVisitorData             
	  end          
	  else          
	  begin          
		 insert into #tempSiteVisitorData (VisitorId,IsNewUser,OTPValue,IsCheckIn,Name,PhotoImageUrl)          
			values (@vVisitorId,0,'1234',0,@vName,@vPhotoImageUrl)          
		 select VisitorId,IsNewUser,OTPValue,IsCheckIn,Name,PhotoImageUrl from #tempSiteVisitorData            
	  end          
	   end              
	   else              
	   begin               
			   insert into #tempSiteVisitorData (VisitorId,IsNewUser,OTPValue,IsCheckIn,Name,PhotoImageUrl)          
			values ('0',1,'1234',0,'','')          
		 select VisitorId,IsNewUser,OTPValue,IsCheckIn,Name,PhotoImageUrl from #tempSiteVisitorData            
	   end              
end  
  
  
   
  
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetVisitorDetails]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[UspVisitor_GetVisitorDetails]                  
 @pTenantId nvarchar(100),                  
 @psearchValue nvarchar(100)                          
AS                                                    
BEGIN        
    
   declare @vOrg nvarchar(100)  
   select @vOrg = OrganizationId from [dbo].[Locations] where id=@pTenantId  
     
   if(exists (select * from [Visitor].[LocationDetails] where TenantId=@pTenantId ANd IsDeleted=0))  
   begin  
   SELECT LD.Id as LocationId, LD.Name as Name, LD.Title as Title, LD.LogoUrl as LogoUrl,                  
   LD.BackgroundUrl as BackGroundUrl, LD.IsOTPRequired as IsOTPRequried  ,
   LD.isPhotoUrl as IsPhotoRequired,LD.isDocumentUrl as IsDocumentRequired
   FROM [Visitor].[LocationDetails] LD    where                     
   LD.TenantId=@pTenantId ANd IsDeleted=0  AND  (LD.Name like '%'+@psearchValue+'%' or                   
   LD.Title like '%'+@psearchValue+'%')  ORDER BY LD.ModifiedOn  desc    
  end  
  else  
    begin  
 declare @vOrgName nvarchar(100)  
 select @vOrgName =  Name from [dbo].[Locations] where id=@vOrg  
   SELECT LD.Id as LocationId,  Name as Name, LD.Title as Title, LD.LogoUrl as LogoUrl,                  
   LD.BackgroundUrl as BackGroundUrl, LD.IsOTPRequired as IsOTPRequried ,
   LD.isPhotoUrl as IsPhotoRequired,LD.isDocumentUrl as IsDocumentRequired
   FROM [Visitor].[LocationDetails] LD    where                     
   LD.TenantId=@vOrg ANd IsDeleted=0  AND  (LD.Name like '%'+@psearchValue+'%' or                   
   LD.Title like '%'+@psearchValue+'%')  ORDER BY LD.ModifiedOn  desc    
  end  
  
END     
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetVisitorDynamicPage]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_GetVisitorDynamicPage]                                                               
 @tenantId nvarchar(50)  ,                                    
 @pStatusId int  ,                        
 @pVisitorid nvarchar(100)                        
as                                                    
begin               
            
            declare @vOrgId nvarchar(100)            
   select @vOrgId = OrganizationId from [dbo].[Locations] where id=  @tenantId            
             
   declare @vdocumentImageUrl nvarchar(100)                      
   declare @vphotoImageUrl nvarchar(100)                      
   declare @vsignatureImageUrl nvarchar(100)                      
                      
   if(@pVisitorid !='0')                      
   begin                      
    select @vphotoImageUrl = PhotoImageUrl,@vdocumentImageUrl = DocumentImageUrl,@vsignatureImageUrl = ApprovedId from [Visitor].[SiteVisitor]                       
    where id=@pVisitorid                      
   end                      
   else                      
   begin                      
    set @vphotoImageUrl = '00.jpg';                      
    set @vdocumentImageUrl = '00.jpg';                      
    set @vsignatureImageUrl = '00.jpg'                      
   end                      
                                 
   select 'Check-in' as Name,@vdocumentImageUrl as documentImageUrl,@vphotoImageUrl as photoImageUrl,@vsignatureImageUrl as signatureImageUrl,            
   1 as isDocumentUrl,1 as isPhotoUrl             
        
     
   select PageId,PageTitle,Header1,Header2,Header3 from  [Visitor].[VisitorHeader] where TenantId = @tenantId and SourceId = @pStatusId  order by PageId                        
    
   select [Visitor].[AssignFieldLocation].PageId,[Visitor].[DynamicFieldOption].Id,[Visitor].[DynamicField].DisplayText,[Visitor].[DynamicField].IsRequired,            
   [Visitor].[DynamicField].DataType,[Visitor].[DynamicField].Type,[Visitor].[DynamicField].DisplayId             
   from [Visitor].[DynamicField] inner join [Visitor].[AssignFieldLocation] on [Visitor].[DynamicField].Id = [Visitor].[AssignFieldLocation].DynamicFieldId            
   inner join [Visitor].[DynamicFieldOption] on [Visitor].[AssignFieldLocation].Id = [Visitor].[DynamicFieldOption].AssignFieldLocationId            
   where [Visitor].[AssignFieldLocation].TenantId =@tenantId and [Visitor].[AssignFieldLocation].SourceId =@pStatusId              
   order by   [Visitor].[AssignFieldLocation].PageId,[Visitor].[AssignFieldLocation].SeqNo           
                              
   select  [Visitor].[SourceData].Id as OptionId,[Visitor].[SourceData].Name as OptionName,[Visitor].[DynamicFieldOption].Id as FieldId,[Visitor].[SourceData].ColorCode,            
   [Visitor].[SourceData].ImageUrl            
   from [Visitor].[DynamicField] inner join [Visitor].[AssignFieldLocation] on [Visitor].[DynamicField].Id = [Visitor].[AssignFieldLocation].DynamicFieldId            
   inner join [Visitor].[DynamicFieldOption] on [Visitor].[AssignFieldLocation].Id = [Visitor].[DynamicFieldOption].AssignFieldLocationId            
   inner join [Visitor].[SourceType] on [Visitor].[DynamicFieldOption].SourceTypeId = [Visitor].[SourceType].Id inner join [Visitor].[SourceData] on            
    [Visitor].[SourceType].Id = [Visitor].[SourceData].SourceTypeId             
      where  [Visitor].[AssignFieldLocation].TenantId =@tenantId and [Visitor].[AssignFieldLocation].SourceId =@pStatusId             
   order by   [Visitor].[SourceData].Name desc            
                         
    select [Visitor].[VisitorDataCollection].DynamicFieldOptionId as DynamicFieldId,[Visitor].[VisitorDataCollection].FieldValue from [Visitor].[VisitorDataCollection]             
 inner join [Visitor].[AssignFieldLocation] on [Visitor].[VisitorDataCollection].AssignFieldLocationId = [Visitor].[AssignFieldLocation].Id            
    inner join [Visitor].[DynamicField] on [Visitor].[AssignFieldLocation].DynamicFieldId =                        
    [Visitor].[DynamicField].Id where [Visitor].[VisitorDataCollection].VisitorId = @pVisitorid and [Visitor].[AssignFieldLocation].SourceId =@pStatusId   
	and [Visitor].[DynamicField].AccessId =1
                                       
end 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetVisitorHeaderById]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[UspVisitor_GetVisitorHeaderById]                                                
  @pId NVARCHAR(100)                                         
AS                                                
BEGIN                                                
   SELECT Id as TitleId, PageId as PageId, PageTitle as TitleName, Header1 as Description         
   FROM [Visitor].[VisitorHeader] VH WHERE VH.Id=@pId and  VH.IsDeleted=0           
                             
END 

GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_GetVisitortype]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_GetVisitortype]                                
             
AS                                                        
BEGIN            
          
 IF OBJECT_ID('tempdb..#tempDatatype') is not null                                                                                                            
    DROP TABLE #tempDatatype                                                                          
    CREATE TABLE  #tempDatatype                                                                                                         
    (VisitorTypeID  nvarchar(500), VisitorTypeName nvarchar(500))               
          
  Insert into #tempDatatype values('1','Visitor');      
  Insert into #tempDatatype values('3','Employee Id Card');    
  Insert into #tempDatatype values('2','Employee Invite Visitor');          
       
          
  select VisitorTypeID,VisitorTypeName from #tempDatatype          
END     
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_PostAssignFieldLocation]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
       
CREATE procedure [dbo].[UspVisitor_PostAssignFieldLocation]                                
 @pVisitorTypeID nvarchar(100),                          
 @pAssignData xml ,              
 @pUserId NVARCHAR(100),                                  
 @pCreatedOn DATETIME,              
 @pTenantId nvarchar(100)              
AS                                                                  
BEGIN                       
                    
    if object_id('tempdb..#VisitorResponse') is not null                                                                                                                                
    drop table #VisitorResponse                                                                                                             
    create TABLE #VisitorResponse                                                                                                                             
    (ResponseStatus bit ,ResponseMessage nvarchar(100))                         
                    
 DECLARE @vDynamicId nvarchar(100);            
  DECLARE @vSourceTypeId nvarchar(100);          
 DECLARE @vPageNo int;          
 DECLARE @vSeqNo  int;          
 DECLARE @Newguid nvarchar(100);              
 DECLARE @IsSourceConnected bit          
           
   If(exists(select Id from [Visitor].[AssignFieldLocation] where IsDeleted=0 and SourceId=@pVisitorTypeID and TenantId=@pTenantId))        
    BEGIN        
     Update [Visitor].[AssignFieldLocation] set IsDeleted=1, ModifiedById=@pUserId, ModifiedOn=@pCreatedOn where  IsDeleted=0 and SourceId=@pVisitorTypeID and TenantId=@pTenantId        
     Update [Visitor].[DynamicFieldOption] set IsDeleted=1, ModifiedById=@pUserId, ModifiedOn=@pCreatedOn where  IsDeleted=0   and TenantId=@pTenantId        
  and AssignFieldLocationId in (select id from [Visitor].[AssignFieldLocation] where SourceId=@pVisitorTypeID and TenantId=@pTenantId)   
  update [Visitor].[VisitorHeader] set IsDeleted=1 where TenantId=@pTenantId and IsDeleted=0 and SourceId = @pVisitorTypeID
 END        
              
          
 DECLARE AssignDataCursor CURSOR FOR                                                                                                      
    SELECT                                                                   
    t.value('(DynamicId/text())[1]','nvarchar(500)')AS vDynamicId ,                                 
    t.value('(PageNo/text())[1]','int')AS vPageNo ,            
    t.value('(SeqNo/text())[1]','int')AS vSeqNo,          
    t.value('(SourceTypeId/text())[1]','nvarchar(500)')AS vSourceTypeId          
    FROM                                                                                                              
    @pAssignData.nodes('/NewDataSet/AssignFieldLocation')AS TempTable(t)                          
    OPEN AssignDataCursor                                                                                                             
    FETCH NEXT FROM AssignDataCursor INTO @vDynamicId, @vPageNo, @vSeqNo ,@vSourceTypeId                                                 
    WHILE @@FETCH_STATUS = 0                                                                                                        
     BEGIN                
  IF(@vSourceTypeId!='')          
   BEGIN          
     set @IsSourceConnected=1;          
   END          
   ELSE          
    BEGIN          
      set @IsSourceConnected=0;          
    END         
    IF(not exists(select id from [Visitor].[AssignFieldLocation] where DynamicFieldId=@vDynamicId and SourceId=@pVisitorTypeID and IsDeleted=1 and TenantId=@pTenantId))        
     BEGIN        
            SET @Newguid=cast(newid() as nvarchar(50));            
    INSERT INTO [Visitor].[AssignFieldLocation](Id, DynamicFieldId, PageId, SeqNo, SourceId, TenantId, CreatedById, CreatedOn, ModifiedById, ModifiedOn, IsDeleted)                                                     
    values (@Newguid,@vDynamicId,@vPageNo, @vSeqNo,@pVisitorTypeID,@pTenantId,  @pUserId,  @pCreatedOn, @pUserId, @pCreatedOn,0 )            
        
    INSERT INTO [Visitor].[DynamicFieldOption](Id, Name, AssignFieldLocationId, DynamicFieldId, ImageURL, IsSourceConnected, SourceTypeId, TenantId, CreatedById, CreatedOn, ModifiedById, ModifiedOn, IsDeleted)                                              
 
    values (NEWID(),null, @Newguid, @vDynamicId, null, @IsSourceConnected,@vSourceTypeId,@pTenantId,  @pUserId,  @pCreatedOn, @pUserId, @pCreatedOn,0 )        
    
      END        
      ELSE        
       BEGIN        
            declare @AssignFieldLocationId nvarchar(100);        
            update [Visitor].[AssignFieldLocation] set IsDeleted=0, PageId=@vPageNo, SeqNo=@vSeqNo,  
   ModifiedById=@pUserId, ModifiedOn=@pCreatedOn where  DynamicFieldId=@vDynamicId and SourceId=@pVisitorTypeID and IsDeleted=1 and TenantId=@pTenantId     
     
   select @AssignFieldLocationId=Id from [Visitor].[AssignFieldLocation]  where  DynamicFieldId=@vDynamicId and SourceId=@pVisitorTypeID and IsDeleted=0 and TenantId=@pTenantId        
   update [Visitor].[DynamicFieldOption] set IsDeleted=0, IsSourceConnected=@IsSourceConnected, SourceTypeId= @vSourceTypeId where   
   IsDeleted=1 and AssignFieldLocationId=@AssignFieldLocationId     
    END      
	
    if(not exists (select * from [Visitor].[VisitorHeader] where PageId= @vPageNo and TenantId=@pTenantId and SourceId = @pVisitorTypeID))  
	BEGIN  
		INSERT INTO [Visitor].[VisitorHeader](Id,PageId,PageTitle,Header1,Header2,Header3,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted,SourceId)                                                
		values (cast(newid() as nvarchar(50)),@vPageNo,'-', '-',null, null,@pTenantId,  @pUserId,  @pCreatedOn, @pUserId, @pCreatedOn,0,@pVisitorTypeID )  
	END
	ELSE
	BEGIN
		Update [Visitor].[VisitorHeader] set  IsDeleted=0 where  PageId= @vPageNo and TenantId=@pTenantId and IsDeleted=1 and SourceId = @pVisitorTypeID
	END                       
          
     FETCH NEXT FROM AssignDataCursor INTO @vDynamicId, @vPageNo, @vSeqNo, @vSourceTypeId            
                
     END                                
     CLOSE AssignDataCursor                                                                                
     DEALLOCATE AssignDataCursor          
          
   insert into #VisitorResponse values (1,'Inserted Successfully')             
                 
    select * from #VisitorResponse          
  END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_PostDynamicField]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE procedure [dbo].[UspVisitor_PostDynamicField]                               
@pName nvarchar(100),               
@pDisplayText nvarchar(100),               
@pIsRequired bit=false,               
@pDataType nvarchar(1000),               
@pTenantId nvarchar(100),               
@pUserId nvarchar(100),               
@pCreatedOn datetime                            
as                                                      
begin                                          
    IF( not Exists(select id from  Visitor.DynamicField where DisplayText=@pDisplayText and TenantId=@pTenantId and IsDeleted=0))      
    BEGIN      
        Insert into Visitor.DynamicField(Id, Name, DisplayText, IsRequired, DataType, AccessId, TenantId, CreatedById, CreatedOn, ModifiedById, ModifiedOn, IsDeleted)              
        values( NEWID(),@pName, @pDisplayText,  @pIsRequired,@pDataType,0, @pTenantId, @pUserId, @pCreatedOn,@pUserId, @pCreatedOn, 0  );                                          
		select 1 as ResponseStatus,'Successfully Inserted' as ResponseMessage
    END      
     ELSE      
   BEGIN       
         select 0 as ResponseStatus,'Already Exits' as ResponseMessage
   END      
                          
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_PostEmployeeIdCard]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[UspVisitor_PostEmployeeIdCard]                      
  @pStatusId int,                      
  @pDate datetime,                      
  @pTenantId nvarchar(100),                      
  @pVisitorId nvarchar(100),                      
  @pUserId nvarchar(100),                      
  @pMobileNo nvarchar(100),                      
  @pVisitorCollection xml                      
as                      
begin                      
      
	  declare @vkey nvarchar(1000)                      
	  declare @vvalue nvarchar(1000)                       
                      
	  declare @vEmployeeId nvarchar(100)                      
	  declare @vName nvarchar(100)                      
	  declare @vEmailId nvarchar(100)                      
	  declare @vMobileNo nvarchar(100)                      
	  declare @vValidFrom datetime             
	  declare @vValidTo datetime
	  declare @vDepartment nvarchar(100)                      
	  declare @vDesignation nvarchar(100)   
  
  
	insert into [Visitor].[EmployeeIdCard] (Id,EmployeeId,Name,EmailId,MobileNo,ValidFrom,ValidTo,Data1,Data2,Data3,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted) 
	values (@pVisitorId,'','','','',@pDate,@pDate,'','','',@pTenantId,@pUserId,@pDate,@pUserId,@pDate,0)        
 
     declare @vIsTriggerNotification bit           
     declare @vAssignFieldLocationId nvarchar(100)         
     declare @vDynamicFieldId nvarchar(100)         
     declare @vDisplayId int     
     declare @vIsSourceIdActivated bit    
                           
	   DECLARE  PostVisitorDataCursor CURSOR FOR                                                    
	   SELECT                                                         
	   t.value('(Key/text())[1]','nvarchar(1000)')AS vkey,                      
	   t.value('(Value/text())[1]','nvarchar(1000)')AS vvalue                       
	   FROM                                                            
	   @pVisitorCollection.nodes('/NewDataSet/VisitorKeyValueDTO')AS TempTable(t)                                                   
                                                  
	   OPEN PostVisitorDataCursor                                                           
	   FETCH NEXT FROM PostVisitorDataCursor INTO @vkey,@vvalue                        
                                                  
	   WHILE @@FETCH_STATUS = 0                                                      
	   BEGIN                
       
		   select @vDynamicFieldId = [Visitor].[DynamicField].Id,@vDisplayId = [Visitor].[DynamicField].DisplayId,@vAssignFieldLocationId = [Visitor].[AssignFieldLocation].Id,    
		   @vIsSourceIdActivated = [Visitor].[DynamicFieldOption].IsSourceConnected    
		   from [Visitor].[DynamicFieldOption] inner join [Visitor].[AssignFieldLocation] on [Visitor].[DynamicFieldOption].AssignFieldLocationId =        
		   [Visitor].[AssignFieldLocation].Id inner join [Visitor].[DynamicField] on [Visitor].[AssignFieldLocation].DynamicFieldId = [Visitor].[DynamicField].Id        
		   where [Visitor].[DynamicFieldOption].Id = @vkey       
           
		   if(@vIsSourceIdActivated = 1)    
		   begin    
				  select @vIsTriggerNotification = IsTriggerNotification from [Visitor].[SourceData]  where Id = @vvalue     
		   end    
		   else  
		   begin  
				  set @vIsTriggerNotification =0  
		   end  
               
			insert into [Visitor].[VisitorDataCollection](Id,FieldValue,AssignFieldLocationId,DynamicFieldId,        
			TenantId,Description,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted,VisitorId,DynamicFieldOptionId,IsTriggerNotification)        
			values (cast(newid() as nvarchar(50)),@vvalue,@vAssignFieldLocationId,@vDynamicFieldId,@pTenantId,@vkey,@pUserId,@pDate,@pUserId,@pDate,0,@pVisitorId,@vkey,@vIsTriggerNotification)     
      
			if(@vIsSourceIdActivated = 1)    
			begin    
			select @vvalue = Name from [Visitor].[SourceData] where id=@vvalue    
			end    
                
			if(@vDisplayId = '1') begin set @vName = @vvalue end else                      
			if(@vDisplayId = '10') begin set @vEmployeeId = @vvalue end else                      
			if(@vDisplayId = '3') begin set @vEmailId = @vvalue end else                      
			if(@vDisplayId = '2') begin set  @vMobileNo= @vvalue end else                      
			if(@vDisplayId = '13') begin set  @vValidFrom= @vvalue end else  
			if(@vDisplayId = '11') begin set  @vDepartment= @vvalue end else  
			if(@vDisplayId = '12') begin set  @vDesignation= @vvalue end else  
			if(@vDisplayId = '14') begin set  @vValidTo= @vvalue end  
           
	   FETCH NEXT FROM PostVisitorDataCursor INTO @vkey,@vvalue                                         
	   END                                                  
	   CLOSE PostVisitorDataCursor                                                             
	   DEALLOCATE PostVisitorDataCursor                       
         
		update [Visitor].[EmployeeIdCard] set Name = @vName,EmployeeId=@vEmployeeId,EmailId=@vEmailId,MobileNo=@vMobileNo,ValidFrom=@vValidFrom,                
		ValidTo=@vValidTo,Data1=@vDepartment,Data2=@vDesignation where Id = @pVisitorId                      
                      
		select [Visitor].[EmployeeIdCard].Id,[Visitor].[EmployeeIdCard].Name,[Visitor].[EmployeeIdCard].EmailId as Email,              
		[dbo].[Locations].Name as CustomerName,[dbo].[Locations].Address as CustomerAddress,[Visitor].[EmployeeIdCard].MobileNo as PhoneNumber,              
		'Employee Id Card' as PassName,[Visitor].[EmployeeIdCard].ValidFrom,[Visitor].[EmployeeIdCard].ValidTo,[Visitor].[EmployeeIdCard].Data1 as Department, 
		[Visitor].[EmployeeIdCard].Data2  as Designation              
		from [Visitor].[EmployeeIdCard] inner join [dbo].[Locations] on               
		[Visitor].[EmployeeIdCard].TenantId = [dbo].[Locations].Id     
		where [Visitor].[EmployeeIdCard].Id = @pVisitorId                      
end
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_PostLocationInformation]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_PostLocationInformation]                             
@pName nvarchar(100),             
@pTitle nvarchar(100),             
@pLogoUrl nvarchar(100),             
@pBackGroundUrl nvarchar(100),             
@pIsOTPRequried bit,       
@pIsMasterData bit,  
@pIsEmployeeIdCard bit, 
@pIsDocumentRequired bit,
@pIsPhotoRequired bit,
@pIsOrgData bit,
@pTenantId nvarchar(100),             
@pUserId nvarchar(100),             
@pCreatedOn datetime                          
as                                                    
begin                                        
         
   if(not exists (select * from [Visitor].[LocationDetails] where TenantId = @pTenantId))    
   begin    
                -- used otp required to orgrequired need to chane
				Insert into [Visitor].[LocationDetails](Id,Name,Title,LogoUrl,BackgroundUrl,IsOTPRequired,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted,isDocumentUrl,isPhotoUrl)            
				values( NEWID(),@pName, @pTitle,  @pLogoUrl,@pBackGroundUrl,@pIsOrgData, @pTenantId, @pUserId, @pCreatedOn,@pUserId, @pCreatedOn, 0,@pIsDocumentRequired,@pIsPhotoRequired);    
				
				if(@pIsOrgData =1)
				begin
				    declare @vOrganizationId nvarchar(100)
				    select @vOrganizationId = OrganizationId from [dbo].[Locations] where id=@pTenantId
					if(not exists(select Id from  [Visitor].[DynamicField] where TenantId = @vOrganizationId))
					begin
							exec dbo.UspVisitor_UploadMasterData @vOrganizationId,@pIsMasterData,@pIsEmployeeIdCard,@pCreatedOn,@pUserId
					end
				end
				else
				if(not exists(select Id from  [Visitor].[DynamicField] where TenantId = @pTenantId))
				begin
				       exec dbo.UspVisitor_UploadMasterData @pTenantId,@pIsMasterData,@pIsEmployeeIdCard,@pCreatedOn,@pUserId
				end

				select 1 as ResponseStatus,'Successfully Inserted' as ResponseMessage                    
      end    
   else    
   begin    
        select 0 as ResponseStatus,'Location Already exists' as ResponseMessage           
   end    
END     
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_PostSourceTypeField]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_PostSourceTypeField]                        
 @pName nvarchar(100),                  
 @pSourceData xml ,      
 @pUserId NVARCHAR(100),                          
 @pCreatedOn DATETIME,      
 @pTenantId nvarchar(100),  
 @pSourceTypeId nvarchar(100)  
AS                                                          
BEGIN               
            
    if object_id('tempdb..#VisitorResponse') is not null                                                                                                                        
    drop table #VisitorResponse                                                                                                     
    create TABLE #VisitorResponse                                                                                                                     
    (ResponseStatus bit ,ResponseMessage nvarchar(100))                 
            
 DECLARE @vSourceData nvarchar(100);   
  DECLARE @vSourceDataId nvarchar(800);     
 DECLARE @vRemarks nvarchar(800);               
 DECLARE @vIsSelected bit;     
   
 DECLARE @Newguid nvarchar(100);      
 set @Newguid=NEWID();      
             
   IF(exists(select id  from [Visitor].[SourceType] where  id=@pSourceTypeId and TenantId =@pTenantId and IsDeleted=0))   
    BEGIN  
     Update [Visitor].[SourceData] set IsDeleted=1 where SourceTypeId=@pSourceTypeId;  
 END  
     
   IF(not Exists(select Id from [Visitor].[SourceType] where id=@pSourceTypeId and TenantId =@pTenantId and IsDeleted=0))      
    BEGIN      
          INSERT INTO [Visitor].[SourceType](Id,Name,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted)                                              
          VALUES(@Newguid,@pName,@pTenantId,@pUserId, @pCreatedOn,@pUserId, @pCreatedOn,0);      
     
       insert into #VisitorResponse values (1,'Inserted Successfully')      
      
     DECLARE SourceDataCursor CURSOR FOR                                                                                              
    SELECT                                                           
    t.value('(sourceData/text())[1]','nvarchar(500)')AS vSourceData ,                         
    t.value('(IsSelected/text())[1]','bit')AS vIsSelected,     
    t.value('(SourceDataId/text())[1]','nvarchar(500)')AS vSourceDataId    
    FROM                                                                                                      
    @pSourceData.nodes('/NewDataSet/SourceDataDTO')AS TempTable(t)                  
    OPEN SourceDataCursor                                                                                                     
    FETCH NEXT FROM SourceDataCursor INTO @vSourceData, @vIsSelected  ,@vSourceDataId                                        
    WHILE @@FETCH_STATUS = 0                                                                                                
    BEGIN        
       
          INSERT INTO [Visitor].[SourceData](Id,Name, SourceTypeId, Description, IsTriggerNotification, ImageUrl, Data1, Data2, Data3, TenantId, CreatedById, CreatedOn, ModifiedById, ModifiedOn, IsDeleted)                                             
          values (NEWID(),@vSourceData,@Newguid, null,@vIsSelected,null,null, null,null,@pTenantId,  @pUserId,  @pCreatedOn, @pUserId, @pCreatedOn,0 )                       
      
         FETCH NEXT FROM SourceDataCursor INTO @vSourceData, @vIsSelected, @vSourceDataId           
        
     END                        
     CLOSE SourceDataCursor                                                                        
     DEALLOCATE SourceDataCursor                        
      select * from  #VisitorResponse         
      
    END      
               
   ELSE      
    begin      
      --INSERT INTO [Visitor].[SourceType](Id,Name,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted)                                              
      --    VALUES(@Newguid,@pName,@pTenantId,@pUserId, @pCreatedOn,@pUserId, @pCreatedOn,0);  
  Update [Visitor].[SourceType] set Name=@pName where id=@pSourceTypeId and TenantId =@pTenantId and IsDeleted=0  
     
     insert into #VisitorResponse values (1,'Updated Successfully')      
      
     DECLARE SourceDataCursor CURSOR FOR                                                                                              
    SELECT                                                           
    t.value('(sourceData/text())[1]','nvarchar(500)')AS vSourceData ,                         
    t.value('(IsSelected/text())[1]','bit')AS vIsSelected,  
    t.value('(SourceDataId/text())[1]','nvarchar(500)')AS vSourceDataId    
    FROM                                                                                                      
    @pSourceData.nodes('/NewDataSet/SourceDataDTO')AS TempTable(t)                  
    OPEN SourceDataCursor                                                                                                     
    FETCH NEXT FROM SourceDataCursor INTO @vSourceData, @vIsSelected , @vSourceDataId                                         
    WHILE @@FETCH_STATUS = 0                                                                                                
    BEGIN        
       
  IF(not exists(select id from [Visitor].[SourceData] where id=@vSourceDataId))  
   BEGIN  
      INSERT INTO [Visitor].[SourceData](Id,Name, SourceTypeId, Description, IsTriggerNotification, ImageUrl, Data1, Data2, Data3, TenantId, CreatedById, CreatedOn, ModifiedById, ModifiedOn, IsDeleted)                                             
          values (NEWID(),@vSourceData,@pSourceTypeId, null,@vIsSelected,null,null, null,null,@pTenantId,  @pUserId,  @pCreatedOn, @pUserId, @pCreatedOn,0 )                       
   END  
      ELSE  
    BEGIN  
       update [Visitor].[SourceData] set IsDeleted=0, IsTriggerNotification=@vIsSelected where id=@vSourceDataId  
    END  
      
         FETCH NEXT FROM SourceDataCursor INTO @vSourceData, @vIsSelected  , @vSourceDataId         
        
     END                        
     CLOSE SourceDataCursor                                                                        
     DEALLOCATE SourceDataCursor     
    
      select * from  #VisitorResponse   
     
    end      
  END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_PostVisitorCollection]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_PostVisitorCollection]                      
  @pCheckInDateTime datetime,                      
  @pCheckOutDateTime datetime,                      
  @pPhotoImageUrl nvarchar(100),                      
  @pDocumentImageUrl nvarchar(100),                      
  @pSignatureImageUrl nvarchar(100),                      
  @pStatusId int,                      
  @pDate datetime,                      
  @pTenantId nvarchar(100),                      
  @pVisitorId nvarchar(100),                      
  @pUserId nvarchar(100),                      
  @pMobileNo nvarchar(100),                      
  @pVisitorCollection xml                      
as                      
begin                      
                      
    if(@pStatusId in (1,2,6))                      
    begin                      
  declare @vIsInvited bit            
  set @vIsInvited =0            
  if(@pStatusId=6)            
  begin            
  set @vIsInvited =1            
  end            
  declare @vkey nvarchar(1000)                      
  declare @vvalue nvarchar(1000)                       
                      
  declare @vName nvarchar(100)                      
  declare @vPhoneNumber nvarchar(100)                      
  declare @vEmail nvarchar(100)                      
  declare @vOrganization nvarchar(100)                      
  declare @vEmployeeName nvarchar(100)                      
  declare @vPurposeId nvarchar(100)                      
  declare @vVisitingDateTime datetime                      
  declare @vClientId nvarchar(100)                      
           
  if(@pMobileNo is null)          
  begin          
  set @pMobileNo ='';          
  end          
                
   if(exists (select * from [Visitor].[SiteVisitor] where PhoneNumber = @pMobileNo and @pMobileNo !=''  and TenantId = @pTenantId))                 
   begin                
       declare @vDbVisitorId nvarchar(100)                
    select top 1 @vDbVisitorId =  id from [Visitor].[SiteVisitor] where PhoneNumber = @pMobileNo and TenantId = @pTenantId  order by createdon desc                    
    select @pPhotoImageUrl = PhotoImageUrl,@pDocumentImageUrl = DocumentImageUrl,@pSignatureImageUrl = SignatureImageUrl from [Visitor].[SiteVisitor]                 
    where id=@vDbVisitorId                 
   end                
                      
  insert into [Visitor].[SiteVisitor] (Id,CheckInDateTime,CheckOutDateTime,                       
  IsApproved,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted,IsNotAccectable,PhotoImageUrl,DocumentImageUrl,ApprovedId,IsInvited,IsCheckedOut,StatusId)                       
  values (@pVisitorId,@pCheckInDateTime,@pCheckOutDateTime,0,@pTenantId,@pUserId,@pDate,@pUserId,@pDate,0,0,@pPhotoImageUrl,@pDocumentImageUrl,@pSignatureImageUrl,@vIsInvited,0,@pStatusId)                
                 
     declare @vIsTriggerNotification bit           
     declare @vAssignFieldLocationId nvarchar(100)         
     declare @vDynamicFieldId nvarchar(100)         
     declare @vDisplayId int     
  declare @vIsSourceIdActivated bit    
                           
   DECLARE  PostVisitorDataCursor CURSOR FOR                                                    
   SELECT                                                         
   t.value('(Key/text())[1]','nvarchar(1000)')AS vkey,                      
   t.value('(Value/text())[1]','nvarchar(1000)')AS vvalue                       
   FROM                                                            
   @pVisitorCollection.nodes('/NewDataSet/VisitorKeyValueDTO')AS TempTable(t)                                                   
                                                  
   OPEN PostVisitorDataCursor                                                           
   FETCH NEXT FROM PostVisitorDataCursor INTO @vkey,@vvalue                        
                                                  
   WHILE @@FETCH_STATUS = 0                                                      
   BEGIN                
               
       
       select @vDynamicFieldId = [Visitor].[DynamicField].Id,@vDisplayId = [Visitor].[DynamicField].DisplayId,@vAssignFieldLocationId = [Visitor].[AssignFieldLocation].Id,    
    @vIsSourceIdActivated = [Visitor].[DynamicFieldOption].IsSourceConnected    
       from [Visitor].[DynamicFieldOption] inner join [Visitor].[AssignFieldLocation] on [Visitor].[DynamicFieldOption].AssignFieldLocationId =        
       [Visitor].[AssignFieldLocation].Id inner join [Visitor].[DynamicField] on [Visitor].[AssignFieldLocation].DynamicFieldId = [Visitor].[DynamicField].Id        
       where [Visitor].[DynamicFieldOption].Id = @vkey       
          
    if(@pTenantId is not null)      
    begin      
  
   if(@vIsSourceIdActivated = 1)    
   begin    
          select @vIsTriggerNotification = IsTriggerNotification from [Visitor].[SourceData]  where Id = @vvalue     
   end    
   else  
   begin  
          set @vIsTriggerNotification =0  
   end  
               
     insert into [Visitor].[VisitorDataCollection](Id,FieldValue,AssignFieldLocationId,DynamicFieldId,        
     TenantId,Description,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted,VisitorId,DynamicFieldOptionId,IsTriggerNotification)        
     values (cast(newid() as nvarchar(50)),@vvalue,@vAssignFieldLocationId,@vDynamicFieldId,@pTenantId,@vkey,@pUserId,@pDate,@pUserId,@pDate,0,@pVisitorId,@vkey,@vIsTriggerNotification)     
      
  if(@vIsSourceIdActivated = 1)    
  begin    
  select @vvalue = Name from [Visitor].[SourceData] where id=@vvalue    
  end    
                
    if(@vDisplayId = '1') begin set @vName = @vvalue end else                      
    if(@vDisplayId = '2') begin set @vPhoneNumber = @vvalue end else                      
    if(@vDisplayId = '3') begin set @vEmail = @vvalue end else                      
    if(@vDisplayId = '4') begin set @vOrganization = @vvalue end else                      
    if(@vDisplayId = '5') begin set @vPurposeId = @vvalue end else                      
    if(@vDisplayId = '6') begin set @vEmployeeName = @vvalue end else                      
    --if(@vDisplayId = '7') begin set @vVisitingDateTime = convert(datetime, @vvalue) end else                      
    if(@vDisplayId = '8') begin set @vClientId = @vvalue end            
   end      
           
   FETCH NEXT FROM PostVisitorDataCursor INTO @vkey,@vvalue                                         
   END                                                  
   CLOSE PostVisitorDataCursor                                                             
   DEALLOCATE PostVisitorDataCursor                       
                      
   set @vVisitingDateTime =   @pCheckInDateTime                
   update [Visitor].[SiteVisitor] set Name = @vName,PhoneNumber=@vPhoneNumber,Email=@vEmail,Organization=@vOrganization,PurposeId=@vPurposeId,                
   EmployeeName=@vEmployeeName,ClientId=@vClientId,                      
   VisitingDateTime = @vVisitingDateTime where Id = @pVisitorId 
   
     select [Visitor].[SiteVisitor].Id,[Visitor].[SiteVisitor].Name,[Visitor].[SiteVisitor].Email,[Visitor].[SiteVisitor].VisitingDateTime,              
    [Visitor].[SiteVisitor].Organization,[Visitor].[SiteVisitor].CheckInDateTime,[Visitor].[SiteVisitor].EmployeeName as UserName,              
    [dbo].[Locations].Name as CustomerName, [dbo].[Locations].Address as CustomerAddress,[Visitor].[SiteVisitor].PhoneNumber,              
    loc.Name as ClientName,purpose.Name as PurposeName,[Visitor].[SiteVisitor].Organization,              
    'Visitor Pass' as PassName              
    from [Visitor].[SiteVisitor] inner join [dbo].[Locations] on               
    [Visitor].[SiteVisitor].TenantId = [dbo].[Locations].Id  left outer  join [Visitor].[SourceData] as loc on              
    [Visitor].[SiteVisitor].ClientId = loc.Id  left outer  join   [Visitor].[SourceData] as purpose        
    on [Visitor].[SiteVisitor].PurposeId = purpose.Id              
    where [Visitor].[SiteVisitor].Id = @pVisitorId 

     end                    
     else if(@pStatusId =3)                  
     begin                  
         update [Visitor].[SiteVisitor] set PhotoImageUrl = @pPhotoImageUrl where Id = @pVisitorId   
		   select [Visitor].[SiteVisitor].Id,[Visitor].[SiteVisitor].Name,[Visitor].[SiteVisitor].Email,[Visitor].[SiteVisitor].VisitingDateTime,              
    [Visitor].[SiteVisitor].Organization,[Visitor].[SiteVisitor].CheckInDateTime,[Visitor].[SiteVisitor].EmployeeName as UserName,              
    [dbo].[Locations].Name as CustomerName, [dbo].[Locations].Address as CustomerAddress,[Visitor].[SiteVisitor].PhoneNumber,              
    loc.Name as ClientName,purpose.Name as PurposeName,[Visitor].[SiteVisitor].Organization,              
    'Visitor Pass' as PassName              
    from [Visitor].[SiteVisitor] inner join [dbo].[Locations] on               
    [Visitor].[SiteVisitor].TenantId = [dbo].[Locations].Id  left outer  join [Visitor].[SourceData] as loc on              
    [Visitor].[SiteVisitor].ClientId = loc.Id  left outer  join   [Visitor].[SourceData] as purpose        
    on [Visitor].[SiteVisitor].PurposeId = purpose.Id              
    where [Visitor].[SiteVisitor].Id = @pVisitorId 
                  
     end                  
      else if(@pStatusId =4)                  
     begin                  
         update [Visitor].[SiteVisitor] set DocumentImageUrl = @pPhotoImageUrl where Id = @pVisitorId   
		   select [Visitor].[SiteVisitor].Id,[Visitor].[SiteVisitor].Name,[Visitor].[SiteVisitor].Email,[Visitor].[SiteVisitor].VisitingDateTime,              
    [Visitor].[SiteVisitor].Organization,[Visitor].[SiteVisitor].CheckInDateTime,[Visitor].[SiteVisitor].EmployeeName as UserName,              
    [dbo].[Locations].Name as CustomerName, [dbo].[Locations].Address as CustomerAddress,[Visitor].[SiteVisitor].PhoneNumber,              
    loc.Name as ClientName,purpose.Name as PurposeName,[Visitor].[SiteVisitor].Organization,              
    'Visitor Pass' as PassName              
    from [Visitor].[SiteVisitor] inner join [dbo].[Locations] on               
    [Visitor].[SiteVisitor].TenantId = [dbo].[Locations].Id  left outer  join [Visitor].[SourceData] as loc on              
    [Visitor].[SiteVisitor].ClientId = loc.Id  left outer  join   [Visitor].[SourceData] as purpose        
    on [Visitor].[SiteVisitor].PurposeId = purpose.Id              
    where [Visitor].[SiteVisitor].Id = @pVisitorId 
     end                  
      else if(@pStatusId =5)                  
     begin                  
         update [Visitor].[SiteVisitor] set SignatureImageUrl = @pPhotoImageUrl where Id = @pVisitorId  
		   select [Visitor].[SiteVisitor].Id,[Visitor].[SiteVisitor].Name,[Visitor].[SiteVisitor].Email,[Visitor].[SiteVisitor].VisitingDateTime,              
    [Visitor].[SiteVisitor].Organization,[Visitor].[SiteVisitor].CheckInDateTime,[Visitor].[SiteVisitor].EmployeeName as UserName,              
    [dbo].[Locations].Name as CustomerName, [dbo].[Locations].Address as CustomerAddress,[Visitor].[SiteVisitor].PhoneNumber,              
    loc.Name as ClientName,purpose.Name as PurposeName,[Visitor].[SiteVisitor].Organization,              
    'Visitor Pass' as PassName              
    from [Visitor].[SiteVisitor] inner join [dbo].[Locations] on               
    [Visitor].[SiteVisitor].TenantId = [dbo].[Locations].Id  left outer  join [Visitor].[SourceData] as loc on              
    [Visitor].[SiteVisitor].ClientId = loc.Id  left outer  join   [Visitor].[SourceData] as purpose        
    on [Visitor].[SiteVisitor].PurposeId = purpose.Id              
    where [Visitor].[SiteVisitor].Id = @pVisitorId 
     end   
	 else if(@pStatusId =7)
	 begin
	        exec dbo.UspVisitor_PostEmployeeIdCard @pStatusId,@pDate,@pTenantId,@pVisitorId,@pUserId,@pMobileNo,@pVisitorCollection
	 end
          
        
                      
                       
end
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_PutDynamicField]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
       
                                  
CREATE procedure [dbo].[UspVisitor_PutDynamicField]            
@pDynamicId nvarchar(100),           
@pName nvarchar(100),                   
@pDisplayText nvarchar(100),                   
@pIsRequired bit=false,                   
@pDataType nvarchar(1000),                   
@pTenantId nvarchar(100),                   
@pUserId nvarchar(100),                   
@pCreatedOn datetime                                
as                                                          
begin                                              
                                            
                            
   if(not Exists(select * from  Visitor.DynamicField where DisplayText=@pDisplayText and id!=@pDynamicId and TenantId =@pTenantId  and IsDeleted=0))          
    BEGIN        
     IF(Exists(select id from  Visitor.DynamicField where id=@pDynamicId  and IsDeleted=0))          
     BEGIN          
     Update Visitor.DynamicField set   DisplayText=@pDisplayText, IsRequired=@pIsRequired, DataType=@pDataType, Type=@pDataType where id=@pDynamicId  and IsDeleted=0       
     select 1 as ResponseStatus,'Successfully Updated' as ResponseMessage      
     END          
     ELSE          
     BEGIN        
     select 0 as ResponseStatus,'Invalid Input' as ResponseMessage      
     END          
     END        
  else        
   BEGIN        
           select 0 as ResponseStatus,'Display Value already exists' as ResponseMessage      
   END        
                              
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_PutVisitorHeader]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
                                
CREATE procedure [dbo].[UspVisitor_PutVisitorHeader]          
@pTitleId nvarchar(100),         
@pTitleName nvarchar(100),                 
@pDescription nvarchar(800),                 
@pTenantId nvarchar(100),                 
@pUserId nvarchar(100),                 
@pCreatedOn datetime                              
as                                                        
begin                                            
  IF(Exists(select * from  [Visitor].[VisitorHeader] VH where VH.Id=@pTitleId  and IsDeleted=0))        
     BEGIN      
       Update [Visitor].[VisitorHeader] set PageTitle=@pTitleName, Header1=@pDescription, ModifiedById=@pUserId, ModifiedOn=@pCreatedOn where Id=@pTitleId  and IsDeleted=0         
	   select 1 as ResponseStatus,'Successfully Updated' as ResponseMessage
     END        
 ELSE        
  BEGIN         
	select 0 as ResponseStatus,'Record Not Found.' as ResponseMessage
  END        
     
END 

GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_SiteVisitorDetailById]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspVisitor_SiteVisitorDetailById]
   @pTenantId nvarchar(100),
   @pVisitorId nvarchar(100) 
as
begin
    select Id,Name,PhoneNumber,Email,Organization,EmployeeName,PurposeId,VisitingDateTime,PhotoImageUrl,DocumentImageUrl  from [Visitor].[SiteVisitor] where 
	id = @pVisitorId

	if object_id('tempdb..#tempVisitorData') is not null                                                                                                                  
    drop table #tempVisitorData                                                                              
    create TABLE  #tempVisitorData                                                                                                             
    (SeqNo int,DisplayText nvarchar(1000),FieldValue nvarchar(1000))    

	if object_id('tempdb..#tempSourceData') is not null                                                                                                                  
    drop table #tempSourceData                                                                            
    create TABLE  #tempSourceData                                                                                                             
    (id nvarchar(1000),Name nvarchar(1000),SourceTypeId nvarchar(100))    

	insert into #tempSourceData 
	select Id,Name,SourceTypeId from [Visitor].[SourceData] where TenantId = @pTenantId
	 

	declare @vSeqNo int
	set @vSeqNo =1
	declare @vDisplayText nvarchar(1000)
	declare @vFieldValue nvarchar(1000)
	declare @vIsSourceConnected bit
	declare @vSourceTypeId nvarchar(100)

	 DECLARE  PostLocationCursor CURSOR FOR                              
     select [Visitor].[DynamicField].DisplayText,[Visitor].[VisitorDataCollection].FieldValue,[Visitor].[DynamicFieldOption].IsSourceConnected,[Visitor].[DynamicFieldOption].SourceTypeId from [Visitor].[SiteVisitor] inner join [Visitor].[VisitorDataCollection] on [Visitor].[SiteVisitor].Id =[Visitor].[VisitorDataCollection].VisitorId
	inner join [Visitor].[DynamicFieldOption] on [Visitor].[VisitorDataCollection].DynamicFieldOptionId = [Visitor].[DynamicFieldOption].Id inner join
	[Visitor].[AssignFieldLocation] on [Visitor].[DynamicFieldOption].AssignFieldLocationId = [Visitor].[AssignFieldLocation].Id inner join 
	[Visitor].[DynamicField] on [Visitor].[AssignFieldLocation].DynamicFieldId = [Visitor].[DynamicField].Id
	where [Visitor].[SiteVisitor].id =@pVisitorId order by [Visitor].[AssignFieldLocation].PageId,[Visitor].[AssignFieldLocation].SeqNo                
     OPEN PostLocationCursor                                     
     FETCH NEXT FROM PostLocationCursor INTO @vDisplayText,@vFieldValue,@vIsSourceConnected,@vSourceTypeId  
                            
     WHILE @@FETCH_STATUS = 0                                
     BEGIN           
    
	  if(@vIsSourceConnected =0)
	  begin
	        insert into #tempVisitorData (SeqNo,DisplayText,FieldValue) values (@vSeqNo,@vDisplayText,@vFieldValue)
	  end
	  else
	  begin
	         select @vFieldValue = Name from #tempSourceData where id=@vFieldValue and SourceTypeId = @vSourceTypeId
			 insert into #tempVisitorData (SeqNo,DisplayText,FieldValue) values (@vSeqNo,@vDisplayText,@vFieldValue)
	  end
	  set @vSeqNo = @vSeqNo +1

     FETCH NEXT FROM PostLocationCursor INTO @vDisplayText,@vFieldValue,@vIsSourceConnected,@vSourceTypeId  
     END                            
     CLOSE PostLocationCursor                                       
     DEALLOCATE PostLocationCursor 

	select SeqNo,DisplayText,FieldValue from #tempVisitorData order by SeqNo
	 
end
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_SiteVisitorDetails]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspVisitor_SiteVisitorDetails]
   @pTenantId nvarchar(100),
   @pFromDate datetime,
   @pToDate datetime
as
begin
    select Id,Name,PhoneNumber,Email,Organization,EmployeeName,PurposeId,VisitingDateTime  from [Visitor].[SiteVisitor] where 
	TenantId = @pTenantId
end
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_SourceTypeAvailability]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[UspVisitor_SourceTypeAvailability]                  
    @pId NVARCHAR(100),              
    @pName NVARCHAR(100),              
    @pTenantid NVARCHAR(100)                        
AS                              
BEGIN                              
		IF(@pId is null)          
	   BEGIN          
		  SET @pId='0';          
	   END 
   
    IF(EXISTS(SELECT ST.Id, ST.Name  FROM [Visitor].[SourceType] ST WHERE             
           LOWER(ltrim(rtrim(ST.Name))) = LOWER(ltrim(rtrim(@pName))) and ST.TenantId = @pTenantid and ST.id != @pId AND ST.IsDeleted=0 ))              
     BEGIN 
	 select 1 as ResponseStatus, 'Exists' as ResponseMessage
             
     END              
     ELSE              
     BEGIN              
	  select 0 as ResponseStatus, 'Not Exists' as ResponseMessage
     END                        
              
     
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_UpdateLocationInformation]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[UspVisitor_UpdateLocationInformation]         
@pLocationId nvarchar(100),               
@pName nvarchar(100),               
@pTitle nvarchar(100),               
@pLogoUrl nvarchar(100),               
@pBackGroundUrl nvarchar(100),               
@pIsOTPRequried bit,               
@pTenantId nvarchar(100),               
@pUserId nvarchar(100),               
@pCreatedOn datetime,    
@pIsMasterData bit,    
@pIsEmployeeIdCard bit,   
@pIsDocumentRequired bit,  
@pIsOrgData bit,
@pIsPhotoRequired bit    
as                                                          
begin                                              
                              
   if(exists(select * from [Visitor].[LocationDetails] where  id=@pLocationId and IsDeleted=0 and TenantId = @pTenantId))        
    BEGIN  
	 -- used otp required to orgrequired need to chane
    update  [Visitor].[LocationDetails] set Name=@pName, Title=@pTitle,        
    LogoUrl=@pLogoUrl, BackgroundUrl=@pBackGroundUrl , IsOTPRequired= @pIsOrgData,
	isDocumentUrl = @pIsDocumentRequired,isPhotoUrl=@pIsPhotoRequired
	where id=@pLocationId and IsDeleted=0  
	
		if(@pIsOrgData =1)
		begin
			declare @vOrganizationId nvarchar(100)
			select @vOrganizationId = OrganizationId from [dbo].[Locations] where id=@pTenantId
			if(not exists(select Id from  [Visitor].[DynamicField] where TenantId = @vOrganizationId))
			begin
					exec dbo.UspVisitor_UploadMasterData @vOrganizationId,@pIsMasterData,@pIsEmployeeIdCard,@pCreatedOn,@pUserId
			end
		end
		else
		if(not exists(select Id from  [Visitor].[DynamicField] where TenantId = @pTenantId))
		begin
				exec dbo.UspVisitor_UploadMasterData @pTenantId,@pIsMasterData,@pIsEmployeeIdCard,@pCreatedOn,@pUserId
		end

      select 1 as ResponseStatus, 'Update successfully' as ResponseMessage 
    END        
    ELSE        
    BEGIN        
          exec  [dbo].[UspVisitor_PostLocationInformation]  @pName,@pTitle,@pLogoUrl,@pBackGroundUrl,@pIsOTPRequried,@pIsMasterData,@pIsEmployeeIdCard,@pIsDocumentRequired,@pIsPhotoRequired,@pIsOrgData,@pTenantId,
          @pUserId,@pCreatedOn
    END        
END 
GO
/****** Object:  StoredProcedure [dbo].[UspVisitor_UploadMasterData]    Script Date: 14-07-2022 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
    
CREATE procedure [dbo].[UspVisitor_UploadMasterData]    
    @pTenantId nvarchar(100),    
 @pIsMasterData bit,      
    @pIsEmployeeIdCard bit,    
 @pCreatedOn datetime,    
 @pCreatedBy nvarchar(100)    
as    
begin    
    
               if(not exists(select Id from  [Visitor].[DynamicField] where TenantId = @pTenantId))    
    begin    
                 declare @vCoronaAccess int    
        declare @vEmployeeAccess int    
        set @vCoronaAccess =-1    
        set @vEmployeeAccess =-1    
        if(@pIsMasterData =1) set @vCoronaAccess =2    
        if(@pIsEmployeeIdCard =1) set @vEmployeeAccess =3    
    
        declare @vDynamicFieldId nvarchar(100)    
    
        declare @vLocationName nvarchar(500)    
        select @vLocationName = Name from [dbo].[Locations] where id=@pTenantId    
    
        declare @vMasterId nvarchar(100)    
        declare @vMasterName nvarchar(100)    
        declare @vMasterDisplayText nvarchar(2000)    
        declare @vMasterIsRequired bit    
        declare @vMasterDataType nvarchar(100)    
        declare @vMasterAccessId int    
        declare @vMasterType nvarchar(100)    
        declare @vMasterDisplayId int    
    
        declare @vAssignFieldId nvarchar(100)    
        declare @vAssignFieldPageId nvarchar(100)    
        declare @vAssignFieldSeqNo nvarchar(100)    
        declare @vAssignFieldSourceId nvarchar(100)    
    
        declare @vAssignFieldLocationId nvarchar(100)    
    
         declare @vDFOId nvarchar(100)    
        declare @vDFOName nvarchar(100)    
        declare @vDFOAssignFieldLocationId nvarchar(100)    
        declare @vDFODynamicFieldId nvarchar(100)    
        declare @vDFOImageURL nvarchar(100)    
        declare @vDFOIsSourceConnected nvarchar(100)    
        declare @vDFOSourceTypeId nvarchar(100)    
    
        declare @vMasterSourceTypeName nvarchar(100)    
        declare @vMasterSourceTypeId nvarchar(100)    
    
        declare @vSourceTypeId nvarchar(100)    
        declare @vDisplayId int    
    
           DECLARE  PostVisitorDynamicFieldCursor CURSOR FOR                                  
        select Id,Name,DisplayText,IsRequired,DataType,AccessId,Type,DisplayId from     
        [Visitor].[DynamicField] where (AccessId =1 or  AccessId =@vCoronaAccess or AccessId =@vEmployeeAccess)      
        and TenantId ='ORG01738739262512779' and    
        IsDeleted =0    
                                
        OPEN PostVisitorDynamicFieldCursor                                         
        FETCH NEXT FROM PostVisitorDynamicFieldCursor INTO @vMasterId,@vMasterName,@vMasterDisplayText,@vMasterIsRequired,@vMasterDataType,@vMasterAccessId,@vMasterType,@vMasterDisplayId      
                                
        WHILE @@FETCH_STATUS = 0                                    
        BEGIN      
            
        set @vDynamicFieldId = cast(newid() as nvarchar(50))    
            
        insert into [Visitor].[DynamicField](Id,Name,DisplayText,IsRequired,DataType,AccessId,TenantId,Type,    
        DisplayId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted)     
        values (@vDynamicFieldId,@vMasterName,@vMasterDisplayText,@vMasterIsRequired,@vMasterDataType,@vMasterAccessId,@pTenantId,@vMasterType,@vMasterDisplayId,    
        @pCreatedBy,@pCreatedOn,@pCreatedBy,@pCreatedOn,0)    
    
        DECLARE  PostVisitorAssignFieldLocationCursor CURSOR FOR                                  
        select Id,PageId,SeqNo,SourceId from [Visitor].[AssignFieldLocation]  where   DynamicFieldId =  @vMasterId                           
                                
        OPEN PostVisitorAssignFieldLocationCursor                                         
        FETCH NEXT FROM PostVisitorAssignFieldLocationCursor INTO @vAssignFieldId,@vAssignFieldPageId,@vAssignFieldSeqNo,@vAssignFieldSourceId      
                                
        WHILE @@FETCH_STATUS = 0                                    
        BEGIN       
             set @vAssignFieldLocationId = cast(newid() as nvarchar(50))    
            
             insert into [Visitor].[AssignFieldLocation](Id,DynamicFieldId,PageId,SeqNo,SourceId,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted)    
          values (@vAssignFieldLocationId,@vDynamicFieldId,@vAssignFieldPageId,@vAssignFieldSeqNo,@vAssignFieldSourceId,@pTenantId,@pCreatedBy,@pCreatedOn,@pCreatedBy,@pCreatedOn,0)    
    
         DECLARE  PostVisitorDynamicFieldOptionCursor CURSOR FOR                                  
                                    select Id,Name,AssignFieldLocationId,DynamicFieldId,ImageURL,IsSourceConnected,SourceTypeId    
         from [Visitor].[DynamicFieldOption] where AssignFieldLocationId = @vAssignFieldId    
         OPEN PostVisitorDynamicFieldOptionCursor                                         
         FETCH NEXT FROM PostVisitorDynamicFieldOptionCursor INTO @vDFOId,@vDFOName,@vDFOAssignFieldLocationId,@vDFODynamicFieldId,@vDFOImageURL,@vDFOIsSourceConnected,@vDFOSourceTypeId      
                                
         WHILE @@FETCH_STATUS = 0                                    
         BEGIN         
             
         if(@vDFOIsSourceConnected =0)    
         begin    
                insert into [Visitor].[DynamicFieldOption](Id,Name,AssignFieldLocationId,DynamicFieldId,ImageURL,    
             IsSourceConnected,SourceTypeId,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted)     
             values (cast(newid() as nvarchar(50)),@vDFOName,@vAssignFieldLocationId,@vDynamicFieldId,@vDFOImageURL,@vDFOIsSourceConnected,@vDFOSourceTypeId,    
             @pTenantId,@pCreatedBy,@pCreatedOn,@pCreatedBy,@pCreatedOn,0)      
         end    
         else    
         begin    
                     
           select  @vMasterSourceTypeName = Name,@vDisplayId = DisplayId from [Visitor].[SourceType] where id=@vDFOSourceTypeId    
    
           if(exists (select * from [Visitor].[SourceType] where DisplayId =@vDisplayId  and TenantId =@pTenantId))    
           begin    
                select top 1 @vSourceTypeId = id from [Visitor].[SourceType] where DisplayId =0 and TenantId =@pTenantId    
           end    
           else    
           begin    
               set @vSourceTypeId = cast(newid() as nvarchar(50))    
            insert into [Visitor].[SourceType](Id,Name,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted,DisplayId)     
            values (@vSourceTypeId,@vMasterSourceTypeName,@pTenantId,@pCreatedBy,@pCreatedOn,@pCreatedBy,@pCreatedOn,0,@vDisplayId)     
            if(@vDisplayId = 8)    
            begin    
               insert into [Visitor].[SourceData](Id,Name,SourceTypeId,Description,IsTriggerNotification,ImageUrl,ColorCode,Data1,Data2,Data3,TenantId,    
               CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted,SeqNo,Data4,Data5,Data6)     
               values (cast(newid() as nvarchar(50)),@vLocationName,@vSourceTypeId,'',0,'','','','','',@pTenantId,@pCreatedBy,@pCreatedOn,@pCreatedBy,@pCreatedOn,0,1,'','','')    
            end    
            else    
            begin    
             insert into [Visitor].[SourceData]    
             select cast(newid() as nvarchar(50)),Name,@vSourceTypeId,Description,IsTriggerNotification,ImageUrl,ColorCode,Data1,Data2,Data3,@pTenantId,@pCreatedBy,@pCreatedOn,@pCreatedBy,@pCreatedOn,0,    
             SeqNo,Data4,Data5,Data6 from [Visitor].[SourceData] where SourceTypeId= @vDFOSourceTypeId and IsDeleted=0            
            end    
           end    
               
               
                
            insert into [Visitor].[DynamicFieldOption](Id,Name,AssignFieldLocationId,DynamicFieldId,ImageURL,    
              IsSourceConnected,SourceTypeId,TenantId,CreatedById,CreatedOn,ModifiedById,ModifiedOn,IsDeleted)     
              values (cast(newid() as nvarchar(50)),@vDFOName,@vAssignFieldLocationId,@vDynamicFieldId,@vDFOImageURL,@vDFOIsSourceConnected,@vSourceTypeId,    
              @pTenantId,@pCreatedBy,@pCreatedOn,@pCreatedBy,@pCreatedOn,0)      
  
  
                  
         end    
        
             
              
         FETCH NEXT FROM PostVisitorDynamicFieldOptionCursor INTO @vDFOId,@vDFOName,@vDFOAssignFieldLocationId,@vDFODynamicFieldId,@vDFOImageURL,@vDFOIsSourceConnected,@vDFOSourceTypeId            
         END                                
         CLOSE PostVisitorDynamicFieldOptionCursor                                           
         DEALLOCATE PostVisitorDynamicFieldOptionCursor     
               
        FETCH NEXT FROM PostVisitorAssignFieldLocationCursor INTO  @vAssignFieldId,@vAssignFieldPageId,@vAssignFieldSeqNo,@vAssignFieldSourceId                     
        END                                
        CLOSE PostVisitorAssignFieldLocationCursor                                           
        DEALLOCATE PostVisitorAssignFieldLocationCursor     
            
    
           
        FETCH NEXT FROM PostVisitorDynamicFieldCursor INTO @vMasterId,@vMasterName,@vMasterDisplayText,@vMasterIsRequired,@vMasterDataType,@vMasterAccessId,@vMasterType,@vMasterDisplayId                       
        END                                
        CLOSE PostVisitorDynamicFieldCursor                                           
        DEALLOCATE PostVisitorDynamicFieldCursor     
  
     insert into [Visitor].[VisitorHeader]
     select cast(newid() as nvarchar(50)),PageId,PageTitle,Header1,Header2,Header3,@pTenantId,@pCreatedBy,@pCreatedOn,@pCreatedBy,@pCreatedOn,0,SourceId 
     from [Visitor].[VisitorHeader] where TenantId='ORG01738739262512779'
     
                 
    end    
  
     
    
    
end    
GO
/****** Object:  StoredProcedure [dbo].[SiteVisitor_userChheckin LocationDetails]    Script Date: 10-12-2023 11:53:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   
CREATE procedure [dbo].[SiteVisitor_userChheckin LocationDetails](        
@visitorId nvarchar(50),        
@checkInDateTime datetime,        
@checkOutDateTime datetime,        
@tenantId nvarchar(50))              
as              
begin              
    if exists(Select 1 From [Visitor].[SiteVisitor] where CheckInDateTime IS NULL and id=@visitorId)        
	begin           
				update [User].[SiteUser] set CheckInDateTime=@checkInDateTime where Id=@visitorId        
	end        
	else        
	begin         
				update [User].[SiteUser] set CheckOutDateTime=@checkOutDateTime,IsCheckedOut =1 where Id=@visitorId        
	end        
    
   select 1 as Status, @visitorId as Id    
        
end           
GO
